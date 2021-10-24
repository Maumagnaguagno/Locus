#!/usr/bin/env ruby
#-----------------------------------------------
# Locus
#-----------------------------------------------
# Mau Magnaguagno
# Ramon Pereira
# Anibal Solon
#-----------------------------------------------
# - AgentSpeak-like environment specification language for Jason
# - Source-to-source compiler
#-----------------------------------------------
# Feb 2015
# - Created
# - Structured as a module
# - Recursive descent parser
# - Metaprogramming to easily extend the conversion
# Mar 2015
# - Tests
#-----------------------------------------------
# TODOs
# - Multi-line comment support /* Comment */
# - Optional condition block for actions
# - Optional condition block for afterActions and beforeActions
# - Arity check for actions
# - Complex formulas in conditions (&/|/~/not/())
# - Unifications
# - Integer support for non string terms
#-----------------------------------------------

module Locus
  extend self

  VERSION = '0.0.1'

  MAP_AGENTS_STRUCTURE = '  private Map<String, String> agents = new HashMap<String, String>();'

  MAP_AGENTS =
'    /* Agent map with class */
    // First argument must be the mas2j filename in order to map agents with their classes
    // environment: TestEnv("ag-names.mas2j")
    try {
      jason.mas2j.parser.mas2j parser = new jason.mas2j.parser.mas2j(new FileInputStream(args[0]));
      MAS2JProject project;
      project = parser.mas();
      for (AgentParameters ap : project.getAgents()) {
        String agName = ap.name;
        for (int cAg = 0; cAg < ap.getNbInstances(); cAg++) {
          String numberedAg = agName;
          if (ap.getNbInstances() > 1) {
            numberedAg += (cAg + 1);
          }
          agents.put(numberedAg, ap.name);
        }
      }
      System.out.println(agents);
    } catch (jason.mas2j.parser.ParseException e) {
      e.printStackTrace();
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    }'

  #-----------------------------------------------
  # Command
  #-----------------------------------------------

  def read(filename)
    group = ''
    count_paren = 0
    string = false
    str = IO.read(filename)
    str.gsub!(/\/\*.*?\*\//m,'')
    str.gsub!(/\n|\/\/.*$/,'')
    str.each_char {|c|
      case c
      when '.'
        if count_paren.zero? and not string
          # Only triggering events can be matched, several blocks are optional
          # [prefix] event[(terms)] [: context] [<- body]
          if group =~ /^\s*([-+~]+)?(\w+)(?:\((.*?)\))?(?:\s*:\s*(.+?))?(?:\s*<-\s*(.+))?\s*$/
            if respond_to?(event = $2)
              prefix = $1
              terms = $3
              context = $4
              body = $5
              terms = terms.split(/\s*,\s*/) if terms
              body = body.split(/\s*;\s*/) if body
              send(event, prefix, terms, context, body)
            else puts "Error: No match for #{event}"
            end
          end
          group.clear
          next
        end
      when '"'
        string = !string
      when '('
        count_paren += 1 unless string
      when ')'
        raise "Unmatched parentheses for #{str}" if not string and (count_paren -= 1) < 0
      end
      group << c
    }
  end

  #-----------------------------------------------
  # Parser
  #-----------------------------------------------

  def parser(command, string, close_command = true, indent = '', terms = nil)
    # Recursive commands are matched
    case command
    # Percept
    when /^([+-])percept\(([^)]+)\)(?:\s*:\s*(.+))?$/
      prefix = $1
      condition = $3
      target, functor, *arguments = $2.split(/\s*,\s*/)
      string << indent
      if condition
        case condition
        when 'true'
          condition = nil
        when 'false'
          return
        else
          string << 'if('
          parser(condition, string, false)
          string << ") {\n  " << indent
        end
      end
      if functor
        string << (prefix == '+' ? 'addPercept(' : 'removePercept(')
        string << "\"#{target}\", " if target != 'all'
        literal = "Literal.parseLiteral(\"#{functor}"
        ground = argument_parser(literal, arguments, terms)
        literal << '")'
        if ground
          index = @literals.index(literal)
          if index
            string << "literal#{index}"
          else
            string << "literal#{@literals.size}"
            @literals << literal
          end
        else
          string << literal
        end
      else
        string << 'clearPercepts('
        string << "\"#{target}\"" if target != 'all'
      end
      string << ')'
      string << ";\n" if close_command
      string << indent << "}\n" if condition
    # State
    when /^((?:\-\+|\+|\-)?)state\((.+)\)$/
      prefix = $1
      predicate, *arguments = $2.split(/\s*,\s*/)
      positive = predicate.delete_prefix!('~') ? false : true
      string << indent
      key = "\"#{predicate}"
      argument_parser(key, arguments, terms)
      key << '"'
      case prefix
      when ''
        string << "#{positive ? '' : '!'}this.state.get(#{key})"
      when '+', '-+'
        string << "this.state.put(#{key}, #{positive})"
      when '-'
        # TODO do not ignore if positive or negative
        # If it removes bob, only (bob,true) can be removed
        # If it removes ~bob, only (bob,false) can be removed
        string << "this.state.remove(#{key})"
      end
      string << ";\n" if close_command
    # AgentClass
    when /^agentClass\((.+)\)$/
      string << "this.agents.get(agName).equals(\"#{$1}\")"
      string << ";\n" if close_command
      @map_agents = true
    # AgentName
    when /^agentName\((.+)\)$/
      string << "agName.equals(\"#{$1}\")"
      string << ";\n" if close_command
    # Consider Java inline
    else
      puts "Warning: the following command is considered Java code:\n  #{command}"
      string << indent << command
      string << ";\n" if close_command
    end
  end

  #-----------------------------------------------
  # Argument parser
  #-----------------------------------------------

  def argument_parser(str, arguments, terms)
    ground = true
    unless arguments.empty?
      str << '('
      arguments.each_with_index {|arg, index|
        if arg.match?(/^[A-Z]/)
          str << "\" + action.getTerm(#{terms.index(arg)}).toString() + \""
          ground = false
        else
          str << arg
        end
        str << ',' if index < arguments.size - 1
      }
      str << ')'
    end
    ground
  end

  #-----------------------------------------------
  # Make string
  #-----------------------------------------------

  def make_string(dataset)
    string = ''
    dataset.each {|command| parser(command, string, true, '    ')}
    string
  end

  #-----------------------------------------------
  # Import string
  #-----------------------------------------------

  def import_string
    string = ''
    @user_imports.each {|i| string << "import #{i};\n"}
    string
  end

  #-----------------------------------------------
  # Constants string
  #-----------------------------------------------

  def constants_string
    string = ''
    @literals.each_with_index {|lit,i| string << "  static final Literal literal#{i} = #{lit};\n"}
    string
  end

  #-----------------------------------------------
  # Actions string
  #-----------------------------------------------

  def actions_string
    string = '      '
    @actions.each {|name, terms, context, body|
      string << "if(action.getFunctor().equals(\"#{name}\")) {\n"
      if context
        string << '        if('
        parser(context, string, false)
        string << ") {\n"
        body.each {|command| parser(command, string, true, '          ', terms)}
        string << "        }\n"
      else
        body.each {|command| parser(command, string, true, '        ', terms)}
      end
      string << '      } else '
    }
    string << "{\n        logger.info(\"executing: \" + action + \", but not implemented!\");\n      }" unless @actions.empty?
    string
  end

  #-----------------------------------------------
  # AgentSpeak events
  #-----------------------------------------------

  def include(prefix, terms, context, body)
    puts "Warning: prefix #{prefix} is ignored for include command" if prefix
    puts "Warning: context #{context} is ignored for include command" if context
    @user_imports.concat(terms) if terms
    puts "Warning: context #{context} is ignored for include command" if context
    puts "Warning: body #{body} is ignored for include command" if body
  end

  def init(prefix, terms, context, body)
    puts "Warning: prefix #{prefix} is ignored for init command" if prefix
    puts "Warning: terms #{terms} is ignored for init" if terms
    puts "Warning: context #{context} is ignored for init" if context
    @init.concat(body) if body
  end

  def stop(prefix, terms, context, body)
    puts "Warning: prefix #{prefix} is ignored for stop command" if prefix
    puts "Warning: terms #{terms} is ignored for stop" if terms
    puts "Warning: context #{context} is ignored for stop" if context
    @stop.concat(body) if body
  end

  def beforeActions(prefix, terms, context, body)
    puts "Warning: prefix #{prefix} is ignored for beforeActions command" if prefix
    puts "Warning: terms #{terms} is ignored for beforeActions" if terms
    puts "Warning: context #{context} is ignored for beforeActions" if context
    @before.concat(body) if body
  end

  def afterActions(prefix, terms, context, body)
    puts "Warning: prefix #{prefix} is ignored for afterActions command" if prefix
    puts "Warning: terms #{terms} is ignored for afterActions" if terms
    puts "Warning: context #{context} is ignored for afterActions" if context
    @after.concat(body) if body
  end

  def action(prefix, terms, context, body)
    puts "Warning: prefix #{prefix} must be '+' for action command" if prefix != '+'
    if body.empty?
      puts "Warning: action #{terms.first} have no body"
    else
      @actions << [terms.shift, terms, context, body]
    end
  end

  #-----------------------------------------------
  # To Java
  #-----------------------------------------------

  def to_java(filename)
    @environment_name = File.basename(filename,'.esl')
    @user_imports = []
    @literals = []
    @init = []
    @stop = []
    @before = []
    @after = []
    @actions = []
    @map_agents = false
    # Read file and match non-recursive commands
    read(filename)
    # Template fields are updated with data
    template = IO.read('locus_env.java')
    template.gsub!('<ENVIRONMENT_NAME>', @environment_name)
    template.sub!('<TIME>', Time.now.to_s)
    template.sub!('<IMPORTS>', import_string)
    template.sub!('<INIT>', make_string(@init))
    template.sub!('<STOP>', make_string(@stop))
    template.sub!('<BEFORE_ACTIONS>', make_string(@before))
    template.sub!('<ACTIONS>', actions_string)
    template.sub!('<AFTER_ACTIONS>', make_string(@after))
    template.sub!('<CONSTANTS>', constants_string)
    # Add map agent code if required
    if @map_agents
      template.sub!('<MAP_AGENTS_STRUCTURE>', MAP_AGENTS_STRUCTURE)
      template.sub!('<MAP_AGENTS>', MAP_AGENTS)
    else
      template.slice!('<MAP_AGENTS_STRUCTURE>')
      template.slice!('<MAP_AGENTS>')
    end
    template
  end
end

#-----------------------------------------------
# Main
#-----------------------------------------------
if $0 == __FILE__
  begin
    if ARGV.size == 1 and ARGV.first != '-h'
      filename = ARGV.first
      if File.exist?(filename)
        # Convert
        javaenv = Locus.to_java(filename)
        # Save to file
        filename.sub!(/esl$/,'java')
        IO.write(filename, javaenv)
        puts "Saved to file #{filename}"
      else puts "File not found: #{filename}!"
      end
    else
      puts 'Use Locus filename.esl'
    end
  rescue
    puts $!, $@
  end
end
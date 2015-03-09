/* ==============================
/ Locus - Bakery
/ Generated at 2015-02-14 22:31:12 -0200
/ ============================== */

import jason.asSyntax.*;
import jason.mas2j.*;
import jason.environment.*;
import java.util.logging.*;
import java.io.*;
import java.util.*;

public class Bakery extends Environment {

  private Logger logger = Logger.getLogger("Bakery_logger");
  private Map<String, Boolean> state = new HashMap<String, Boolean>();
  private Map<String, String> agents = new HashMap<String, String>();
  static final Literal literal0 = Literal.parseLiteral("~have(pie)");
  static final Literal literal1 = Literal.parseLiteral("~have(cake)");
  static final Literal literal2 = Literal.parseLiteral("~have(donut)");
  static final Literal literal3 = Literal.parseLiteral("have(pie)");
  static final Literal literal4 = Literal.parseLiteral("have(cake)");
  static final Literal literal5 = Literal.parseLiteral("have(donut)");

  /* Called before the MAS execution with the args informed in .mas2j */
  @Override
  public void init(String[] args) {
    super.init(args);
    /* Agent map with class */
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
    }
    this.state.put("have(pie)", false);
    this.state.put("have(cake)", false);
    this.state.put("have(donut)", false);
    addPercept("boss", literal0);
    addPercept("boss", literal1);
    addPercept("boss", literal2);

  }

  /* Execute action at run-time */
  @Override
  public boolean executeAction(String agName, Structure action) {
    /* Before actions */
    clearPercepts();

    /* Actions */
    try {
      logger.info(agName + " calls action " + action);
      if(action.getFunctor().equals("pinTask")) {
        if(agName.equals("boss")) {
          addPercept(Literal.parseLiteral("newTask(" + action.getTerm(0).toString() + ")"));
        }
      } else if(action.getFunctor().equals("bake")) {
        if(this.agents.get(agName).equals("cooker")) {
          this.state.put("have(" + action.getTerm(0).toString() + ")", true);
        }
      } else {
        logger.info("executing: " + action + ", but not implemented!");
      }
    } catch (Exception e) {
      logger.log(Level.SEVERE, "error executing " + action + " for " + agName, e);
    }
    /* After actions */
    if(!this.state.get("have(pie)")) {
      addPercept("boss", literal0);
    }
    if(!this.state.get("have(cake)")) {
      addPercept("boss", literal1);
    }
    if(!this.state.get("have(donut)")) {
      addPercept("boss", literal2);
    }
    if(this.state.get("have(pie)")) {
      addPercept("boss", literal3);
    }
    if(this.state.get("have(cake)")) {
      addPercept("boss", literal4);
    }
    if(this.state.get("have(donut)")) {
      addPercept("boss", literal5);
    }

    return true;
  }

  /* Called before the end of MAS execution */
  @Override
  public void stop() {
    super.stop();

  }
}

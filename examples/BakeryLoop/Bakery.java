/* ==============================
/ Locus - Bakery
/ Generated at 2015-02-14 22:07:51 -0200
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
        if(this.agents.get(agName).equals("baker")) {
          addPercept(Literal.parseLiteral("done(" + action.getTerm(0).toString() + ")"));
        }
      } else {
        logger.info("executing: " + action + ", but not implemented!");
      }
    } catch (Exception e) {
      logger.log(Level.SEVERE, "error executing " + action + " for " + agName, e);
    }
    /* After actions */

    return true;
  }

  /* Called before the end of MAS execution */
  @Override
  public void stop() {
    super.stop();

  }
}

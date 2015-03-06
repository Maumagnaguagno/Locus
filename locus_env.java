/* ==============================
/ Locus - <ENVIRONMENT_NAME>
/ Generated at <TIME>
/ ============================== */

import jason.asSyntax.*;
import jason.mas2j.*;
import jason.environment.*;
import java.util.logging.*;
import java.io.*;
import java.util.*;
<IMPORTS>
public class <ENVIRONMENT_NAME> extends Environment {

  private Logger logger = Logger.getLogger("<ENVIRONMENT_NAME>_logger");
  private Map<String, Boolean> state = new HashMap<String, Boolean>();
<MAP_AGENTS_STRUCTURE>
<CONSTANTS>
  /* Called before the MAS execution with the args informed in .mas2j */
  @Override
  public void init(String[] args) {
    super.init(args);
<MAP_AGENTS>
<INIT>
  }

  /* Execute action at run-time */
  @Override
  public boolean executeAction(String agName, Structure action) {
    /* Before actions */
<BEFORE_ACTIONS>
    /* Actions */
    try {
      logger.info(agName + " calls action " + action);
<ACTIONS>
    } catch (Exception e) {
      logger.log(Level.SEVERE, "error executing " + action + " for " + agName, e);
    }
    /* After actions */
<AFTER_ACTIONS>
    return true;
  }

  /* Called before the end of MAS execution */
  @Override
  public void stop() {
    super.stop();
<STOP>
  }
}

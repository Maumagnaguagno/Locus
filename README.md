<img src="Logo.png" alt="Locus" width="94" height="47">
--------------------

[Jason](http://jason.sourceforge.net/) is an AgentSpeak interpreter for multi-agent system development. The agents are describbed in AgentSpeak, but the environment requires a Java description of how the actions and perceptions happen. We aim to close the gap between the descriptions with an AgentSpeak-like description of the environment, targeting new users and simpler examples. Locus generates the Java source required by Jason, giving the user an easier starting point to create complex environments without limiting the user to the tool. The Java output can be further modified if required.

## The Language

AgentSpeak uses plans to describe agent behavior. Those plans are made of a triggering event, a new perception or belief, happening at a given context, current state, is enough to execute the action in the body of the plan.

```
triggeringEvent : context <- body .
```

With this in mind we created some constructs to affect the environment at specific points in time. **Init** is triggered at the initialization of the environment. **Stop** us triggered at the end of the simulation. **BeforeActions** and **afterActions** can be used to clear and add perceptions dependending of the current state.
Each action added to the environment has a name and N terms, can be applied every time it is called with a context evaluating to true.

```
init                                  <- body.

beforeActions                         <- body.
+action(name[, terms]) : context      <- body.
afterActions                          <- body.

stop                                  <- body.
```

The body of these constructs can be used to add or remove perceptions, add, remove or overwrite the current state.

```
+percept(agent|all, predicate[, terms]) : context.
-percept(agent|all, predicate[, terms]) : context.

+state(predicate[, terms]);
-state(predicate[, terms]);
-+state(predicate[, terms]);
```

## Examples

We hope the next examples show the power of the description.

### Room

![](examples/Room/Prometheus_Room.png)  

ToDo

### Bakery react

ToDo

### Bakery loop

ToDo

## ToDo's

- Finish this readme
- Add perception checks
- Add belief check

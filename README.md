<img src="Logo.png" alt="Locus" width="94" height="47">
--------------------

> [Jason](http://jason.sourceforge.net/) is an AgentSpeak interpreter for multi-agent system development. The agents are describbed in AgentSpeak, but the environment requires a Java description of how the actions and perceptions happen. We aim to close the gap between the descriptions with an AgentSpeak-like description of the environment, targeting new users and simpler examples. Locus generates the Java source required by Jason, giving the user an easier starting point to create complex environments without limiting the user to the tool. The Java output can be further modified if required.

## The Language

AgentSpeak uses plans to describe agent behavior. Those plans are made of a triggering event, a new perception or belief, happening at a given context, current state, is enough to execute the action in the body of the plan.

```
triggeringEvent : context <- body .
```

With this in mind we created some constructs to affect the environment at specific points in time. **init** is triggered at the initialization of the environment. **stop** is triggered at the end of the simulation. **beforeActions** and **afterActions** can be used to clear and add perceptions dependending of the current state.
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

We hope the next examples show the power of the description. The room example is part of the Jason set of examples and is maintained without modifications to show compatibility while the others were created by us to explore what we considered important without adding complex behaviors.

### Room

In the room application we have 3 agents sharing the same room with a door:
- a porter, the only agent who controls the door
- a claustrophobe, an agent who wants the door to be open
- a paranoid, an agent who wants the door to be closed

The environment's door starts either closed or opened. All agents perceive the state of the door. The claustrophobe or paranoid agent perceive the door in the correct position and does nothing, the other will ask the porter to fix the situation. The porter simply obeys, having no desire for any particular door state. Once the porter finishes the action the process restarts. A Prometheus design shows the room application:

![Prometheus design](examples/Room/Prometheus_Room.png)  

We can follow the specification to build the agents and the environment:
- [Porter](examples/Room/porter.asl)
  ```
  +!locked(door)[ source(paranoid)     ] : ~locked(door) <-   lock.
  +!~locked(door)[source(claustrophobe)] :  locked(door) <- unlock.
  ```

- [Paranoid](examples/Room/paranoid.asl)
  ```
  +~locked(door) : true <- .send(porter,achieve,locked(door)). // ask porter to lock the door
  +locked(door)  : true <- .print("Thanks for locking the door!").
  ```

- [Claustrophobe]((examples/Room/claustrophobe.asl))
  ```
  +locked(door) : true <- .send(porter,achieve,~locked(door)). // ask porter to unlock the door
  -locked(door) : true <- .print("Thanks for unlocking the door!").
  ```

- [Room Environment](examples/Room/RoomEnv.esl) (already described in Locus, generate this [Java](examples/Room/RoomEnv.java)) 
  ```
  init <-
    +state(doorLocked);
    +percept(all, locked, door).
  
  beforeActions <-
    -percept(all).
  
  +action(lock) : agentClass(porter) <-
    -+state(doorLocked).
  
  +action(unlock) : agentClass(porter) <-
    -+state(~doorLocked).
  
  afterActions <-
    +percept(all, locked, door) : state(doorLocked);
    +percept(all, ~locked, door) : state(~doorLocked).
  ```

### Bakery react

![Prometheus design](examples/BakeryReact/Prometheus_Bakery.png)  
ToDo

## How it works internally

ToDo

## Execution

With your **.esl** file ready you can launch Ruby to make the conversion to Java, the output is a file in the same folder of the file provided as input. 

```
ruby Locus.rb MyEnvironment.esl
```

Note that a file named RoomEnv.esl will generate RoomEnv.java and RoomEnv must be present in your setup file (**.mas2j**) to be used as your environment. Since we rely on the setup file to obtain the agent's class during run-time we expect to receive the setup filename in the arguments of the environment, like this:

```
MAS room {
    infrastructure: Centralised
    environment: RoomEnv("Room.mas2j")
    executionControl: jason.control.ExecutionControl
    agents: porter; claustrophobe; paranoid;
}
```

## ToDo's

- Finish this readme
- Add a list of commands
- Add Travis CI to this project
- Add perception checks
- Add belief check

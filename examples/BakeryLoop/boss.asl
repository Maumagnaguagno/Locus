!start.

/* Plans */
+!start <-
  +task(pie);
  +task(cake);
  +task(donut);
  !loop.
  
+!loop <-
  ?task(X);
  pinTask(X);
  -task(X);
  .wait(1000);
  !loop.

-!loop <-
  .wait(1000);
  !loop
.

+done(C) <-
  .print("Done ", C);
  .wait(3000);
  +task(C)
.
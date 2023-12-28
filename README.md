# Minisynthea

This helps you to generate realistic longitudinal patient data using simply defined probabilistic state machines.

todo: extract this as a gem

# Fundamental concepts

Patients with certain demographic characteristics and attributes:

* can be reached at a certain rate
* are willing to be enrolled in programs at a particular rate

When they are enrolled in a particular program you can then change the probabilities to reflect measures or expected benefits.

Patients transition between particular states at the probabilities defined by your state machine. 

For example: well -> sick -> well, or sick or ed etc...

After transitions, you can record events. The system knows how to record encounters for ED visits, and hospital stays (which will track length of stay)

Future work to consider:

* have a disenrollment rate for patients, have a future unreachable rate
* consider modelling insurane and insurance changees



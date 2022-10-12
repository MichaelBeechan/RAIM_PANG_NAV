# RAIM_PANG_NAV
RAIM for PANG NAV a tool for processing GNSS measurements in SPP, including RAIM functionality
Global Navigation Satellite Systems (GNSSs) are theoretically able to provide accurate, three-dimensional, and continuous 
positioning to an unlimited number of users. An important shortcoming of GNSS is the lack of integrity, defned as the ability 
of a system to provide timely warnings in case of malfunction; this problem is especially felt in safety-of-life applications 
such as aviation. A common way to fll this gap is the use of Receiver Autonomous Integrity Monitoring (RAIM) techniques, 
which are able to provide integrity information by analyzing redundant measurements. A possible RAIM functionality is the 
ability to identify, and so discard, anomalous measurements; this functionality has made RAIM very useful also in case of 
severe signal degradation, such as in urban or dense vegetation areas, where blunders are common. PANG-NAV is a tool, 
developed by the PArthenope Navigation Group, able to process GNSS measurements (from RINEX fles) in order to obtain 
a position solution. The core of PANG-NAV is the single point positioning (SPP) technique, including a RAIM functionality. 
A multi-constellation solution, with GPS and Galileo, can be provided. Both static processing and kinematic processing are 
possible, and in cases where ground truth is available, error analysis can be carried out.

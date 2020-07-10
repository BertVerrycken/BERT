# BERT
Bit-Efficient Replicator Tech for X, Y, Z axis motor control (3D printers)

Open source development of the digital circuit desciption in both VHDL and verilog (systemverilog).
Every source file has a VHDL and a verilog equivalent for training and educational purposes.

The community is available on locals and started validating the stepper motor control with an A4988
driver IC board and the Digilent Arty S7-50 FPGA board (it has an Arduino shield header).

Both Marlin and Klipper are software based 3D printer control solutions for a wide range of
single board computers (SBC) and shields/hats/add-on boards.

Software executes sequentially on a controller. By writing and reading IO registers the stepper motor
drivers are controlled via software. But interrupts servicing sensors (thermistors measuring the heat
bed temperature) will take time away from the control of the motors.

An FPGA does not have that problem since an FPGA is a digital circuit that is reconfigurable.
We can move 5 motors in parallel without interfering with each other.
And for monitoring and driving the colling fans, we can implement a sofisticated algorithm that
operates in parallel and isn't bound by program memory restrictions. The restriction is in the
digital circuitry that is available in the FPGA.

We implement the digital circuit in a Hardware Descrption Language (HDL). It describes hardware,
while it has a software syntax. It abstracts the underlying technology (FPGA; asic, vendor, ...).
And allows automated verification with self-checking test cases. We can always rerun all verification
scenario's and see if all PASSED or not whenever we change the HDL source code.

For validation, I use the Arty S7-50 aforementioned since I have it available. But in principle, the
design is portable to any technology that supports the use of a digital circuit design.

The MAIN benefit is the parallel control and monitoring versus software (firmware) approaches.
We intend to run at clock frequencies higher than 100 MHz to have high resolution stepper motor
control. It is basically a hardware accelerator for 3D printers where we have one X-axis,
one Y-axis, two Z-axis and one extruder motor (Reprap, Prusa, MK2S, MK3S).
The simplest driver, A4988, is used to validate the circuit on target.
But obviously, additional driver IC's could be supported in the future.

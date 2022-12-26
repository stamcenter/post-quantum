# To run this example, bring up the simulator and type the following at the prompt:
#     do run.do
# or, to run from a shell, type the following at the shell prompt:
#     vsim -c -do run.do
# (omit the "-c" to see the GUI while running from the shell)
# Remove the "quit -f" command from this file to view the results in the GUI.


onbreak {resume}

# Create the library.
if [file exists work] {
    vdel -all
}
vlib work

# Compile the sources.
vlog ../sources/gaussian.v
vlog ../sources/gaussian_coef.v
vlog ../sources/gaussian_ctg.v
vlog ../sources/gaussian_interp.v
vlog ../sources/gaussian_lzd.v
vlog ../sources/gaussian_smul_16_18.v
vlog ../sources/gaussian_smul_16_18_sadd_37.v
vlog ../testbeds/tb_gaussian.sv


# Simulate the design.
vsim -novopt -c tb_gaussian
run -all

quit -f

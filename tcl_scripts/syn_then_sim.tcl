reset_runs synth_1
launch_runs synth_1 -jobs 8

wait_for [get_runs synth_1]

#close_sim
#reset_simulation -simset sim_1 -mode post-synthesis -type functional
#launch_simulation -mode post-synthesis -type functional
#launch_simulation -mode post-synthesis -type timing

# Check the status of the synthesis run
if {[get_runs synth_1 status] eq "completed"} {
    puts "Synthesis complete. Starting simulation..."
    # Launch simulation after synthesis is done
    if []
    launch_simulation -mode post-synthesis -type functional
} else {
    puts "Synthesis failed or is not completed. Exiting."
    exit
}
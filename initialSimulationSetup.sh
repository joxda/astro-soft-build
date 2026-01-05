indiwebmanagercli --host localhost --port 8624 create-profile Simulation
indiwebmanagercli --host localhost --port 8624 add-driver Simulation indi_simulator_telescope
indiwebmanagercli --host localhost --port 8624 add-driver Simulation indi_simulator_ccd
indiwebmanagercli --host localhost --port 8624 add-driver Simulation indi_simulator_focuser
indiwebmanagercli --host localhost --port 8624 add-driver Simulation indi_simulator_guider
indiwebmanagercli --host localhost --port 8624 add-driver Simulation indi_gpsd
indiwebmanagercli --host localhost --port 8624 set-profile-option Simulation autostart true
indiwebmanagercli --host localhost --port 8624 set-profile-option Simulation autoconnect true
indiwebmanagercli --host localhost --port 8624 get-profile Simulation
indiwebmanagercli --host localhost --port 8624 start-profile Simulation

simion.workbench_program()

-- end of stability diagram: f=1e6, RF_amp=7000V
-- stabil: f=1e5, RF_amp=30V

adjustable RF_freq                  = 1e5 -- Hz 1e5
adjustable RF_amp_in                = 25   -- V 30
adjustable RF_amp_out               = 50   -- V 30
adjustable DC_ring_in               = 0.0
adjustable DC_ring_out              = 0.0 -- -0.15 --2
adjustable DC_segments              = 0 -- -0.15 --2

-- Stokes damping
adjustable linear_damping          = 1   -- linear damping factor

local next_time = 0
local time_step = 20
local omega    


-- ==============================================================
function segment.initialize() 
	number_of_ions = ion_number	-- store the number of ions started in this simulation
end

-- ==============================================================
function segment.init_p_values()

    adj_elect[1] = DC_segments
    adj_elect[2] = DC_segments
    adj_elect[3] = DC_segments
    adj_elect[4] = DC_segments
    
    omega = RF_freq * (1E-6 * 2 * math.pi)

end

-- ==============================================================
function segment.tstep_adjust()
    -- Keep time step under some fraction of the RF period
    ion_time_step = min(ion_time_step, (0.1*1E+6)/RF_freq)  -- X usec
end

 
-- ==============================================================
function segment.accel_adjust()
    if ion_time_step == 0   then return end -- skip if zero time step
    if linear_damping == 0 then return end -- skip if damping set to zero

    -- Compute correction factor.
    linear_damping = abs(linear_damping)         -- force damping factor positive
    local tterm = ion_time_step * linear_damping  -- time constant
    local factor = (1 - exp(-tterm)) / tterm       -- correction factor

    -- Compute new x, y, and z accelerations.
    -- This following the differential equation
    --   da/dt = -v*linear_damping
    -- with the correction factor for dt being finite.
    -- Note: ion_v[xyz]_mm is particle velocity in mm/usec.
    --       ion_a[xyz]_mm is particle acceleration in mm/usec^2.
    ion_ax_mm = factor * (ion_ax_mm - ion_vx_mm * linear_damping)
    ion_ay_mm = factor * (ion_ay_mm - ion_vy_mm * linear_damping)
    ion_az_mm = factor * (ion_az_mm - ion_vz_mm * linear_damping)
end

-- ==============================================================
function segment.fast_adjust()

    local phase = math.sin(ion_time_of_flight * omega)
    local tempvolts_in = RF_amp_in * phase
    local tempvolts_out = RF_amp_out * phase

    adj_elect[5] = tempvolts_out + DC_ring_out
    adj_elect[6] = tempvolts_in + DC_ring_in

    -- adj_elect[1] = quad1
    -- adj_elect[2] = DC_segments
    -- adj_elect[3] = quad1
    -- adj_elect[4] = DC_segments
end

-- ==============================================================
function segment.other_actions()

	if ion_time_of_flight >= next_time + time_step then 

		next_time = ion_time_of_flight

		local speed = math.sqrt(ion_vx_mm^2 + ion_vy_mm^2 + ion_vz_mm^2)
		local ke = simion.speed_to_ke(speed,ion_mass)

		--print(ion_time_of_flight,ke,ion_px_mm,adj_elect[1],adj_elect[2],adj_elect[3],adj_elect[4],adj_elect[5],adj_elect[6])
		print(ion_px_mm, ion_py_mm, ion_pz_mm, ion_time_of_flight, ke)

	end
end



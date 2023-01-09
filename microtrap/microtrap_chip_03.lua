simion.workbench_program()

-- adjustable RF_freq                  = 3e4  -- Hz
-- adjustable RF_amp                   = 100   -- V
-- adjustable DC_segments              = 0
-- adjustable DC_parabola              = 1
-- adjustable DC_ring                  = 1

-- end of stability diagram: f=1e6, RF_amp=7000V
-- stabile: f=1e5, RF_amp=30V

adjustable RF_freq                  = 1e5 -- Hz 1e5
adjustable RF_amp                   = 50   -- V 30
adjustable DC_parabola              = 0.0 -- 0.15 --1
adjustable DC_ring_inner            = 0.0
adjustable DC_ring_outer            = 0 -- -0.15 --2
adjustable DC_segments              = 0 -- -0.15 --2

-- adjustable RF_freq                  = 1e5  -- Hz
-- adjustable RF_amp                   = 1000   -- V
-- adjustable DC_segments              = 0
-- adjustable DC_parabola              = 1
-- adjustable DC_ring                  = 1


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
    
    adj_elect[5] = DC_ring_outer
    adj_elect[7] = DC_parabola

    omega = RF_freq * (1E-6 * 2 * math.pi)

end

-- ==============================================================
function segment.fast_adjust()

    local tempvolts = RF_amp * math.sin(ion_time_of_flight * omega)

    adj_elect[6] = tempvolts + DC_ring_inner

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
		print(ion_time_of_flight, ke)

	end
end

-- ==============================================================
function segment.tstep_adjust()
   ion_time_step = min(ion_time_step, 0.1*1E+6/RF_freq)  -- X usec
end


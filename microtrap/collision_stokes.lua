-- Stokes' law collision model
--
-- See the SIMION "drag" example for more detail discussion on
-- the following code.
--
-- D.Manura-2006-08 - based drag\drag.lua example.
-- (c) 2006 Scientific Instrument Services, Inc. (Licensed under SIMION 8.0)


-- Stokes' law damping factor (if enabled)
adjustable _linear_damping      = 1.0    -- linear damping factor

local STOKES = {}
STOKES.segment = {}

-- Apply Stokes' law viscous effects to ion motion.
-- This is designed to be called inside a SIMION accel_adjust segment.
function STOKES.segment.accel_adjust()
    if ion_time_step == 0   then return end -- skip if zero time step
    if _linear_damping == 0 then return end -- skip if damping set to zero

    -- Compute correction factor.
    _linear_damping = abs(_linear_damping)         -- force damping factor positive
    local tterm = ion_time_step * _linear_damping  -- time constant
    local factor = (1 - exp(-tterm)) / tterm       -- correction factor

    -- Compute new x, y, and z accelerations.
    -- This following the differential equation
    --   da/dt = -v*linear_damping
    -- with the correction factor for dt being finite.
    -- Note: ion_v[xyz]_mm is particle velocity in mm/usec.
    --       ion_a[xyz]_mm is particle acceleration in mm/usec^2.
    ion_ax_mm = factor * (ion_ax_mm - ion_vx_mm * _linear_damping)
    ion_ay_mm = factor * (ion_ay_mm - ion_vy_mm * _linear_damping)
    ion_az_mm = factor * (ion_az_mm - ion_vz_mm * _linear_damping)
end

return STOKES

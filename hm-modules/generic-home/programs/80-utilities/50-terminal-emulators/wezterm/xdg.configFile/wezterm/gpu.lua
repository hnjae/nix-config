local M = {}

M.apply = function(opts, wezterm)
  opts.webgpu_power_preference = "LowPower"

  for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
    -- if gpu.backend == "Vulkan" and gpu.device_type == "IntegratedGpu" then
    if gpu.backend == "Vulkan" and gpu.device_type ~= "Cpu" then
      opts.webgpu_preferred_adapter = gpu
      opts.front_end = "WebGpu"
      break
    end
  end
end

return M

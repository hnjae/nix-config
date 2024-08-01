{
  systemMonitor = {
    title = "System Monitor";
    displayStyle = "org.kde.ksysguard.piechart";
    sensors = [
      {
        name = "cpu/all/usage";
        color = "137,78,88";
        label = "CPU %";
      }
      # {
      #   name = "gpu/all/usage";
      #   color = "104,137,78";
      #   label = "GPU %";
      # }
      {
        name = "memory/physical/usedPercent";
        color = "94,137,78";
        label = "RAM %";
      }
    ];
  };
}

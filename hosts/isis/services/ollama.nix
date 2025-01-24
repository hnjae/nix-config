# https://llamaimodel.com/requirements/
# https://www.reddit.com/r/LocalLLaMA/comments/139yt87/notable_differences_between_q4_2_and_q5_1/
# 8b-instruct # instruct 가 훈련 모델이라 이걸 써야한다고.
# https://github.com/ggerganov/llama.cpp/discussions/2094#discussioncomment-6351796
# run `sudo podman exec -it ollama ollama pull llama3.2` to pull image
{ config, ... }:
let
  serviceName = "ollama";
in
{
  virtualisation.oci-containers.containers."${serviceName}" = {
    image = "docker.io/ollama/ollama:rocm";
    autoStart = true;
    environment = {
      # ALL environment variables: https://github.com/ollama/ollama/issues/2941#issuecomment-2322778733

      # https://github.com/ollama/ollama/blob/main/docs/faq.md#how-does-ollama-handle-concurrent-requests
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_MAX_QUEUE = "1";
      OLLAMA_MAX_VRAM = toString (4 * 1024 * 1024 * 1024);

      # default: `f16`
      OLLAMA_KV_CACHE_TYPE = "q4_0"; # uses 1/4 the memory of `f16`

      # https://github.com/ollama/ollama/blob/main/docs/gpu.md
      # 2024-08-02: gfx1103 (7840U 의 780M) 은 지원되지 않음.
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
    volumes = [
      "/usr/local/share/ollama:/root/.ollama" # ZFS datasets
    ];
    ports = [
      "11434:11434"
    ];
    extraOptions = [
      "--memory=8G"
      "--cpus=8"
      "--device=/dev/kfd"
      "--device=/dev/dri"
    ];
    # https://ollama.com/library
    # ${lib.escapeShellArg (lib.getExe ollamaPackage)} pull "$model" (model == llama3.1)
  };

  home-manager.sharedModules = [
    {
      home.shellAliases.ollama = "sudo podman exec -it ollama ollama";
      services.flatpak.packages = [
        "com.jeffser.Alpaca" # ollama
      ];
    }
  ];
}

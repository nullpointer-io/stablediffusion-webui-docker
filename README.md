# Linux Docker for Stable Diffusion Webui

Build and run the Stable Diffusion Webui in Docker on Linux.

This project is based on the Windows variant:
https://github.com/Sharrnah/stable-diffusion-docker

It will be kept in sync with the original project. 

## Setup Reference

Tested with following computer setup:
- Linux operating system (Ubuntu 22.04.1)
- Python 3.9.7 (managed by pyenv)
- Nvidia GPU RTX 3060 (12 GB GPU RAM)
- 15 GB RAM.

## Restriction

Restriction apply only when RAM equals or is less than 15 GB. 

When starting up the webui maybe the process can run out of memory. 
The webui process will be killed then. Unfortunately I had no luck
with my fine tuning attempt with PYTORCH_CUDA_ALLOC_CONF.

I will try it again in some time. My workaround at the moment: Close 
all unnecessary programs at the start of the Stable Diffusion Webui.
After the start the RAM consumption of the Webui is no problem anymore.

## Prerequisites

- Docker installed. At best case without the need for sudo. This can be done
  by adding your user to the group `docker`.
- Up-to-date Nvidia drivers installed. Tested with original Nvidia drivers version 510.85.02.
- Nvidia Container Toolkit installed. 
  See: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html 

## Installation

1. Clone the repository:
   ``` 
   git clone https://github.com/nullpointer-io/stablediffusion-webui-docker
   ```

2. Change into the project directory:
   ``` 
   cd stablediffusion-webui-docker
   ```

3. Build Docker image:
   ``` 
   ./webui.sh build
   ```
4. Edit the file **env** and uncomment your favorite GPU configuration.

   Optionally:
 
     - WEBUI_RELAUNCH: Comment it in if you experience that the Webui gets 
       unresponsive quite often because the process died within the Docker
       container.
     - ENABLE_TEXTUAL_INVERSION: Currently it will break LDSR so it is not
       enabled. If you need it then comment it in. 

5. Run Stable Diffusion Webui:
   ``` 
   ./webui.sh run
   ```
6. Watch the automatic download of the AI models after executing `./webui.sh run`:
   ```
   docker logs -f stablediffusion-webui
   ```
   The AI models are downloaded automatically when the related files are missing in
   `./share/facexlib` and `./share/models`.
   All information about the models (URLs, hashes, etc.) are configured in the file
   `build/entrypoint.sh`.

   Optional: Backup the downloaded models.

7. Final result:

   - A Docker container with the name `stablediffusion-webui` is available.
   - The webui is listening on http://127.0.0.1:7860.

## Usage

Open the URL http://127.0.0.1:7860. 

How to use the Stable Diffusion Webui: https://github.com/sd-webui/stable-diffusion-webui

Output files are stored to `./output`.

## References

- https://rentry.org/GUItard
- https://github.com/sd-webui/stable-diffusion-webui
- https://github.com/Hafiidz/latent-diffusion
- https://github.com/Sharrnah/Stable-Diffusion-Docker

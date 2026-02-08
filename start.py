import os
import shutil
import subprocess
import json
import sys

# --- CONFIG ---
ROOT = "/workspace"
COMFY_DIR = os.path.join(ROOT, "ComfyUI")
NODES_CONFIG = "config/nodes.json"
MODELS_CONFIG = "config/models.json"
MODEL_SOURCES = "config/model_sources.txt"

def run_cmd(cmd, cwd=None):
    print(f">> Running: {cmd}")
    subprocess.run(cmd, shell=True, check=True, cwd=cwd)

def setup():
    # 1. Clean up existing install
    if os.path.exists(COMFY_DIR):
        print("Cleaning up old ComfyUI installation...")
        shutil.rmtree(COMFY_DIR)
    
    # 2. Clone fresh ComfyUI
    run_cmd(f"git clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git {COMFY_DIR}")

    # 3. Setup Custom Nodes
    if os.path.exists(NODES_CONFIG):
        with open(NODES_CONFIG, 'r') as f:
            nodes = json.load(f)
        
        custom_nodes_path = os.path.join(COMFY_DIR, "custom_nodes")
        for node in nodes:
            if node.get("local"): continue
            
            node_path = os.path.join(custom_nodes_path, node["folder"])
            if not os.path.exists(node_path):
                print(f"Installing {node['name']}...")
                run_cmd(f"git clone --depth 1 {node['url']} {node_path}")

    # 4. Install Requirements
    print("Installing dependencies...")
    run_cmd(f"pip install -r requirements.txt", cwd=COMFY_DIR)
    # Install additional common deps often missing in basic pods
    run_cmd("pip install onnxruntime-gpu setuptools pydantic", cwd=COMFY_DIR)

    # 5. Sync Workflows
    print("Syncing workflows...")
    workflow_src = "assets/workflows/workflows"
    workflow_dest = os.path.join(COMFY_DIR, "user/default/workflows")
    
    if os.path.exists(workflow_src):
        if not os.path.exists(workflow_dest):
            os.makedirs(workflow_dest, exist_ok=True)
        
        for f in os.listdir(workflow_src):
            if f.endswith(".json"):
                 shutil.copy(os.path.join(workflow_src, f), workflow_dest)
                 print(f"Copied: {f}")

    print("\n" + "="*40)
    print("Setup complete! You can now start ComfyUI with:")
    print(f"python {COMFY_DIR}/main.py --listen --port 8188")
    print("="*40)

if __name__ == "__main__":
    if not os.path.exists(ROOT):
        print("Error: /workspace not found. Are you on RunPod?")
        sys.exit(1)
    setup()

import os
import shutil
import subprocess
import json
import sys

# --- CONFIG ---
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = "/workspace"
COMFY_DIR = os.path.join(ROOT, "ComfyUI")
NODES_CONFIG = os.path.join(SCRIPT_DIR, "config/nodes.json")
MODELS_CONFIG = os.path.join(SCRIPT_DIR, "config/models.json")
MODEL_SOURCES = os.path.join(SCRIPT_DIR, "config/model_sources.txt")
WORKFLOW_SRC = os.path.join(SCRIPT_DIR, "assets/workflows/workflows")

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
                
            # Install requirements for this specific node if they exist
            req_file = os.path.join(node_path, "requirements.txt")
            if os.path.exists(req_file):
                print(f"Installing requirements for {node['name']}...")
                run_cmd(f"pip install -r {req_file}")

    # 4. Install Requirements
    print("Installing main dependencies...")
    run_cmd(f"pip install -r requirements.txt", cwd=COMFY_DIR)
    # Install additional common deps often missing in basic pods
    print("Installing universal dependencies...")
    run_cmd("pip install onnxruntime-gpu setuptools pydantic opencv-python onnx scikit-image colorama facexlib", cwd=COMFY_DIR)

    # 5. Sync Workflows and Assets
    print("Syncing workflows and assets...")
    workflow_dest = os.path.join(COMFY_DIR, "user/default/workflows")
    
    # Copy styles.csv to ComfyUI root
    styles_src = os.path.join(SCRIPT_DIR, "styles.csv")
    if os.path.exists(styles_src):
        shutil.copy(styles_src, os.path.join(COMFY_DIR, "styles.csv"))
        print("Copied: styles.csv")

    # Ensure model subdirectories exist (helps some nodes find models)
    model_dirs = [
        "models/ultralytics/bbox",
        "models/sams"
    ]
    for d in model_dirs:
        os.makedirs(os.path.join(COMFY_DIR, d), exist_ok=True)

    if os.path.exists(WORKFLOW_SRC):
        if not os.path.exists(workflow_dest):
            os.makedirs(workflow_dest, exist_ok=True)
        
        for f in os.listdir(WORKFLOW_SRC):
            if f.endswith(".json"):
                 shutil.copy(os.path.join(WORKFLOW_SRC, f), workflow_dest)
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

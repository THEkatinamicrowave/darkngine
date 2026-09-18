import os
import json

# Name of the redundant metadata key inside your chart files
META_KEY_TO_REMOVE = "meta" 

# This automatically finds the folder where your script is saved and looks for a 'songs' folder inside it
script_dir = os.path.dirname(os.path.abspath(__file__))
songs_dir = os.path.join(script_dir, "songs")
if not os.path.exists(songs_dir):
    print("Error: 'songs' directory not found here! Make sure to run this script in the root folder containing your 'songs' directory.")
else:
    processed_count = 0
    for root, dirs, files in os.walk(songs_dir):
        # Target files only inside 'charts' folders
        if os.path.basename(root) == "charts":
            for filename in files:
                if filename.endswith(".json"):
                    filepath = os.path.join(root, filename)
                    
                    with open(filepath, "r", encoding="utf-8") as f:
                        try:
                            data = json.load(f)
                        except json.JSONDecodeError:
                            print(f"Skipping invalid JSON: {filepath}")
                            continue
                    
                    # Check if the metadata key exists in the chart file
                    if META_KEY_TO_REMOVE in data:
                        del data[META_KEY_TO_REMOVE]
                        
                        # Save the cleaned file back out
                        with open(filepath, "w", encoding="utf-8") as f:
                            json.dump(data, f, indent=4)
                        
                        print(f"Cleaned chart: {filepath}")
                        processed_count += 1

    print(f"\nDone! Successfully cleaned {processed_count} chart files across your songs.")
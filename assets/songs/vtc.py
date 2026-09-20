import json
import sys


def rename_keys(data):
    """Recursively renames 'd' to 'id', 't' to 'time', and 'l' to 'sLen' in the JSON structure."""
    if isinstance(data, dict):
        new_dict = {}
        for k, v in data.items():
            # Apply key replacements
            new_key = k
            if k == "d":
                new_key = "id"
            elif k == "t":
                new_key = "time"
            elif k == "l":
                new_key = "sLen"
            
            # Recursively process the value
            new_dict[new_key] = rename_keys(v)
        return new_dict
    elif isinstance(data, list):
        return [rename_keys(item) for item in data]
    else:
        return data


def shift_note_ids(data):
    """Recursively finds 'id' fields and shifts them down by 4 if they are >= 4."""
    if isinstance(data, dict):
        for k, v in data.items():
            if k == "id":
                try:
                    numeric_id = int(v)
                    if numeric_id >= 4:
                        data[k] = numeric_id - 4
                except (ValueError, TypeError):
                    pass
            else:
                shift_note_ids(v)
    elif isinstance(data, list):
        for item in data:
            shift_note_ids(item)


def fix_strumlines():
    if len(sys.argv) < 2:
        print("Error: Please provide the path to the JSON file.")
        print("Usage: python script_name.py path_to_chart.json")
        return

    songname = sys.argv[1]
    songvariant = sys.argv[2]
    songdiff = sys.argv[3]

    if songvariant == "":
        filepath = songname + "/charts/" + songdiff + ".json"
    else:
        filepath = songname + "/charts/" + songvariant + "/" + songdiff + ".json"

    # Load the JSON file
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    # 1. BEFORE: Rename the keys
    data = rename_keys(data)

    # 2. STRUMLINE LOGIC
    dad_strumline = None
    boyfriend_strumline = None

    for strumline in data.get("strumLines", []):
        position = strumline.get("position")
        if position == "dad":
            dad_strumline = strumline
        elif position == "boyfriend":
            boyfriend_strumline = strumline

    if dad_strumline and boyfriend_strumline:
        notes_to_keep = []
        notes_to_move = []

        for note in dad_strumline.get("notes", []):
            note_id = note.get("id")
            try:
                numeric_id = int(note_id)
                if 0 <= numeric_id <= 3:
                    notes_to_move.append(note)
                else:
                    notes_to_keep.append(note)
            except (ValueError, TypeError):
                notes_to_keep.append(note)

        dad_strumline["notes"] = notes_to_keep

        if "notes" not in boyfriend_strumline:
            boyfriend_strumline["notes"] = []
        boyfriend_strumline["notes"].extend(notes_to_move)

    # 3. AFTER: Shift IDs (4->0, 5->1, etc.)
    shift_note_ids(data)

    # Save changes back to the same file
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4)

    print(f"Successfully processed and updated {filepath}!")


if __name__ == "__main__":
    fix_strumlines()

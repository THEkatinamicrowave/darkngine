import json
import sys


def fix_strumlines():
  if len(sys.argv) < 2:
    print("Error: Please provide the path to the JSON file.")
    print("Usage: python script_name.py path_to_chart.json")
    return

  # Use command line argument for the file path
  file_path = sys.argv[1]
  output_path = file_path  # output_file is always input_file

  # Load the JSON file
  with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

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

  # Save changes back to the same file
  with open(output_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)

  print(f"Successfully processed and updated {output_path}!")


if __name__ == "__main__":
  fix_strumlines()
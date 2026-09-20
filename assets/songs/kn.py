import sys
import json


def killit():
	if len(sys.argv) < 2:
		print("Error: your shit sucks bro")
		return

	filepath = sys.argv[1]

	with open(filepath, "r", encoding="utf-8") as f:
		data = json.load(f)

	for sl in data.get("strumLines", []):
		sl["notes"] = []

	with open(filepath, "w", encoding="utf-8") as f:
		json.dump(data, f, indent=4)

	print("Should work???? I think????????? Hello????????????????????????")

if __name__ == "__main__":
	killit()
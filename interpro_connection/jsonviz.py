import json

def print_json_structure(data, indent=2):
    """
    Recursively prints the structure of JSON data.
    """
    if isinstance(data, dict):
        print("{")
        for key, value in data.items():
            print(" " * indent + str(key) + ": ", end="")
            print_json_structure(value, indent + 2)
        print(" " * (indent - 2) + "}")
    elif isinstance(data, list):
        print("[")
        for item in data:
            print(" " * indent, end="")
            print_json_structure(item, indent + 2)
        print(" " * (indent - 2) + "]")
    else:
        print(data)

# Replace 'your_file.json' with the path to your JSON file
with open('Tryp_search_result.json', 'r') as file: 
    json_data = json.load(file)

print_json_structure(json_data)
import names
import csv
import math

def generate_unique_names(num_names, num_ous):

    unique_names = []
    users_per_ou = math.ceil(num_names / num_ous)
    ous = ["MKT", "SLS", "ENG", "FIN", "HR", "IT", "RnD", "CS", "OPS",
        "LGL", "PRD", "PR", "DSN", "MGMT", "SEC"]
    current_ou_index = 0
    current_user = 1
    seen_names = set()

    for _ in range(num_names):
        while True:
            name = names.get_first_name()
            surname = names.get_last_name()
            full_name = f"{name} {surname}"

            if full_name not in seen_names:
                seen_names.add(full_name)
                break

        ou = ous[current_ou_index]

        unique_names.append({
            "name": name,
            "surname": surname,
            "ou": ou,
            "domain": "akm",
            "tld": "local"
        })

        if (current_ou_index + 1) < len(ous) and (current_user) % users_per_ou == 0:
            current_ou_index += 1
            current_user = 1
        current_user += 1

    return unique_names

def write_to_csv(unique_names, filename="unique_names.csv"):

    try:
        with open(filename, "w", newline="") as csvfile:
            fieldnames = ["name", "surname", "ou", "domain", "tld"]
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

            writer.writeheader()
            for name in unique_names:
                writer.writerow(name)
        print(f"CSV file '{filename}' created successfully.")
    except Exception as e:
        print(f"Error writing to CSV file: {e}")

if __name__ == "__main__":
    num_names = 5000
    num_ous = 15
    unique_names = generate_unique_names(num_names, num_ous)
    write_to_csv(unique_names)
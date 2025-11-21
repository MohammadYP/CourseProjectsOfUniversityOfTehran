def format_lines(input_filename, output_filename):
    with open(input_filename, "r") as infile:
        lines = [line.strip() for line in infile.readlines()]  # Read input lines

    with open(output_filename, "w") as outfile:
        for i, line in enumerate(lines):
            address = f"{i * 4:08X}"  # Compute hex address (8-char uppercase)
            outfile.write(f"{address}_{line}\n")  # Write formatted line

    print(f"Formatted {len(lines)} lines. Output saved to {output_filename}")

# Example usage
input_file = "input.txt"   # Replace with your actual input filename
output_file = "output.txt" # Replace with your actual output filename
format_lines(input_file, output_file)

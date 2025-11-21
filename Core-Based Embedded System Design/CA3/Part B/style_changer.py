# File paths
input_file = "factorial_interrupt.txt"     # Replace with your actual input file
output_file = "converted_data.txt" # Output file

def convert_line(line):
    if '_' in line:
        _, hex_value = line.strip().split('_')
        # Split into bytes: 2 hex characters each
        bytes_list = [hex_value[i:i+2] for i in range(0, len(hex_value), 2)]
        # Reverse byte order
        bytes_list.reverse()
        return bytes_list
    return []

def main():
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            reversed_bytes = convert_line(line)
            for b in reversed_bytes:
                outfile.write(b + '\n')

if __name__ == "__main__":
    main()

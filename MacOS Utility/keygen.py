from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from binascii import hexlify

def pretty_print_byte_array(byte_array, label):
    print(f"{label} (Decimal):")
    print(", ".join(f"{byte}" for byte in byte_array))

# Generate a 16-byte AES key
key = get_random_bytes(32)

# Initialize AES cipher in CBC mode with a random initialization vector (IV)
cipher = AES.new(key, AES.MODE_CBC)

# Pretty-print the AES key and IV
pretty_print_byte_array(key, "AES Key")
pretty_print_byte_array(cipher.iv, "Initialization Vector (IV)")

# Convert the AES key and IV to Base-16 (hexadecimal) format
key_hex = hexlify(key).decode('utf-8')
iv_hex = hexlify(cipher.iv).decode('utf-8')

print(f"Base-16 (Hex) AES Key: {key_hex}")
print(f"Base-16 (Hex) IV: {iv_hex}")
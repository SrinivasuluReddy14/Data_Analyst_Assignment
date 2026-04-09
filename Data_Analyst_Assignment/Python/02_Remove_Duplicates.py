# 02_Remove_Duplicates.py

text = input("Enter string: ")

result = ""

for ch in text:
    if ch not in result:
        result = result + ch

print("Result:", result)
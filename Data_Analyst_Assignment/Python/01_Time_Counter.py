# 01_Time_Converter.py

minutes = int(input("Enter minutes: "))

hours = minutes // 60
remaining_minutes = minutes % 60

print(hours, "hrs", remaining_minutes, "minutes")
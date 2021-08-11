import pandas as pd

number_of_interns = int(input("Enter the number of interns: "))
name_list = []
school_list = []

for i in range(number_of_interns):
    name = input(f"Enter Intern {i} name: ")
    name_list.append(name)
    school = input("Enter their school: ")
    school_list.append(school)


data = {'Names':name_list, 'Schools':school_list}
df = pd.DataFrame(data, columns = ['Names', 'Schools'])

df.to_csv("interns_zn.csv")

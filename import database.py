import pandas as pd
from sqlalchemy import create_engine

# Setup
excel_file = 'SQL Test Data.xlsx'  
engine = create_engine('mysql+pymysql://root:23044898321aB!@localhost/gambling')

# Process each sheet
for sheet_name in pd.ExcelFile(excel_file).sheet_names:
    df = pd.read_excel(excel_file, sheet_name=sheet_name)
    
    if sheet_name == 'Betting':
        # Split Betting sheet into two tables
        df_main = df.iloc[:, 0:9].dropna(how='all')
        df_summary = df.iloc[:, 16:25].dropna(how='all')
        df_summary.columns = ['AccountNo', 'Vegas', 'Sportsbook', 'Games', 
                              'Casino', 'Poker', 'Bingo', 'Others', 'Adjustments']
        
        # Save and import
        df_main.to_csv('Betting_main.csv', index=False)
        df_main.to_sql('betting_main', engine, index=False, if_exists='replace')
        
        df_summary.to_csv('Betting_summary.csv', index=False)
        df_summary.to_sql('betting_summary', engine, index=False, if_exists='replace')
        
    elif sheet_name == 'Student_School':
        # Split Student_School into two tables
        df_no_header = pd.DataFrame(df.values)
        df_no_header = df_no_header.drop([0, 1], errors='ignore').reset_index(drop=True)
        
        student_table = df_no_header.iloc[:, 0:5].dropna(subset=[0])
        school_table = df_no_header.iloc[:, 7:10].dropna(subset=[7]).drop_duplicates(subset=[7])
        
        # Add headers BEFORE saving to CSV
        student_table.columns = ['student_id', 'student_name', 'city', 'class', 'grade']
        school_table.columns = ['school_id', 'school_name', 'location']
        
        # Save CSVs with headers# Removed header=False
        student_table.to_csv('student_table.csv', index=False)  
        school_table.to_csv('school_table.csv', index=False)  
        
        # Import to MySQL
        student_table.to_sql('student', engine, index=False, if_exists='replace')
        school_table.to_sql('school', engine, index=False, if_exists='replace')
        
    else:
        # Regular sheets (Account, Customer, Product)
        df.to_csv(f'{sheet_name}.csv', index=False)
        table_name = sheet_name.lower()
        df.to_sql(table_name, engine, index=False, if_exists='replace')

print("All data imported to MySQL successfully!")
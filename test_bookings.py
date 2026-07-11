import mysql.connector
from mysql.connector import Error

CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YOUR_MYSQL_PASSWORD",
    "database": "LittleLemonDB"
}

def print_result(cursor, label):
    rows = cursor.fetchall()
    print(f"{label}: {rows}")
    while cursor.nextset():
        if cursor.with_rows:
            print(cursor.fetchall())

connection = None
cursor = None

try:
    connection = mysql.connector.connect(**CONFIG)
    cursor = connection.cursor()

    cursor.execute("CALL GetMaxQuantity()")
    print_result(cursor, "GetMaxQuantity")

    cursor.execute("CALL ManageBooking(%s, %s)", ("2022-12-12", 8))
    print_result(cursor, "ManageBooking available table")

    cursor.execute("CALL ManageBooking(%s, %s)", ("2022-12-10", 5))
    print_result(cursor, "ManageBooking reserved table")

    cursor.execute(
        "CALL AddBooking(%s, %s, %s, %s)",
        (99, 99, 99, "2022-12-10")
    )
    print_result(cursor, "AddBooking")

    cursor.execute(
        "CALL UpdateBooking(%s, %s)",
        (99, "2022-01-10")
    )
    print_result(cursor, "UpdateBooking")

    cursor.execute("CALL CancelBooking(%s)", (99,))
    print_result(cursor, "CancelBooking")

    connection.commit()

except Error as error:
    print(f"MySQL error: {error}")

finally:
    if cursor is not None:
        cursor.close()
    if connection is not None and connection.is_connected():
        connection.close()

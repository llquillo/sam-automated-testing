import psycopg2
from os import environ
from psycopg2.extras import RealDictCursor


class Database(object):
    _conn = None
    _cursor = None
    _in_transaction_block = False

    def __init__(self, db_cursor=None):
        self._in_transaction_block = False
        if db_cursor:
            self._in_transaction_block = True
            self._cursor = db_cursor
            self._conn = db_cursor.connection
        self.connect()

    def connect(self):
        if self._conn is None:
            conn_str = "host={} dbname={} user={} password={} port={}".format(
                environ.get('DB_HOST'), environ.get('DB_NAME'),
                environ.get('DB_USER'), environ.get('DB_PASSWORD'),
                environ.get('DB_PORT', '5432')
            )
            print(conn_str)
            try:
                self._conn = psycopg2.connect(conn_str)
            except Exception as err:
                raise err

            if self._conn is None:
                print("Not connected!")

    def cursor(self, cursor_factory=RealDictCursor):
        if self._cursor:
            return self._cursor
        if self._conn:
            self._cursor = self._conn.cursor(cursor_factory=cursor_factory)
        return self._cursor

    def commit(self):
        if self._conn:
            self._conn.commit()
            self._cursor = None

    def rollback(self):
        if self._conn:
            self._conn.rollback()
            self._cursor = None

    def close(self):
        if self._conn:
            self._conn.close()
            self._conn = None
            self._cursor = None

    def __enter__(self):
        self._in_transaction_block = True
        return self.cursor()

    def __exit__(self, type, value, traceback):
        if traceback is None:
            self.commit()
        else:
            self.rollback()
        self._in_transaction_block = False

    def execute(self, query=None, values=None, with_return=True):
        result = None
        if self._conn is None:
            self.connect()
        cursor = self.cursor()
        if cursor:
            try:
                cursor.execute(query, values)
                if with_return:
                    result = cursor.fetchone()
            except Exception as e:
                if self._in_transaction_block:
                    raise e
                else:
                    self._conn.rollback()
            if not self._in_transaction_block:
                self._conn.commit()
        return result

    def execute_all(self, query=None, values=None, return_cursor=False):
        result = None
        if self._conn is None:
            self.connect()
        cursor = self.cursor()
        if cursor:
            try:
                cursor.execute(query, values)
                if return_cursor:
                    result = cursor
                else:
                    result = cursor.fetchall()
            except Exception as e:
                if self._in_transaction_block:
                    raise e
                else:
                    self._conn.rollback()
            if not self._in_transaction_block:
                self._conn.commit()
        return result

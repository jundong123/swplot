SRC=i_cal_s3.c

OBJ=i_cal_s3.o

TARGET=i_cal_s3.so

all: $(TARGET)

$(OBJ):	$(SRC)
	gcc -Wall -fPIC -c $(SRC)

$(TARGET): $(OBJ)
	gcc -shared -o $(TARGET) $(OBJ)

install:
	cp $(TARGET) ../bin

clean:
	rm $(OBJ) $(TARGET)


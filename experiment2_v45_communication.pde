/**************************
Stimluation
2019 October 23
***************************/



import java.util.Arrays;
import processing.serial.*;
import controlP5.*;
import processing.net.*; 

ControlP5 cp5;
RadioButton r1;
Group g2,g3;
Button but1;

// TCP communication
Client myClient;
int[][][] data = new int[3][5][10];

// The serial port:
Serial myPort;       

//user definitions
String COM_PORT="COM27"; //change this!

//software definitions
final int PC_ESP32_STIM_PATTERN=0xFF;
final int PC_ESP32_MEASURE_REQUEST=0xFE;
final int PC_ESP32_POLARITY_CHANGE=0xFD;
final int ESP32_PC_RECEIVE_FINISHED = 0xFE;
final int ESP32_PC_MEASURE_RESULT=0xFF;
final int ESP32_PC_ACKNOWLEDGE=0xFD;

boolean SerialDataSendRequest=false;
boolean StimDataSending=false;
boolean FirstMeasurement = true;



//Drawing variable
 final int ELECTRODE_NUM=63;
 
 
//Data convertion and filtering

final int SENSOR_DIM=30;
final int NEW_DIM=20;
final int number_fingers=3;
final int sen_cols=5;
final int sen_rows=6;
final int red_cols=4;
final int red_rows=5;
final int P_max=255;
final int Rand_max=10;

//final int[] Factors = {100, 50, 25, 17, 13, 10, 0};
//final String[] Value_Factors = {"0.1", "0.2","0.4","0.6","0.8","1", "Orig"};

//final int[] Factors = {100, 66, 41, 33, 28, 25, 22, 20, 17, 12, 0};
//final String[] Value_Factors = {"0.1", "0.15","0.24","0.30","0.35", "0.40","0.45","0.50","0.58","78", "Orig"};

final int[] Factors = {100, 79, 53, 42, 35, 30, 26, 21, 15, 14, 0};
final String[] Value_Factors = {"0.1", "0.12","0.19","0.23","0.28","0.32", "0.38","0.46","0.66","0.73", "Orig"};


//patern drawing

 final float[] Electrode_Pos_X ={
          -0.857, -0.857, -0.857, -0.857,-0.857,      -0.714, -0.714,-0.714,-0.714,-0.714,       -0.571,-0.571,-0.571,-0.571,-0.571,        -0.428, -0.428,-0.428,-0.428,-0.428,     -0.62,    
           -0.143, -0.143, -0.143, -0.143,-0.143,           0,      0,     0,     0,     0,       0.143,  0.143, 0.143, 0.143, 0.143,         0.286,  0.286, 0.286, 0.286, 0.286,      0.07,                
           0.571,  0.571,  0.571,  0.571, 0.571,        0.714, 0.714, 0.714, 0.714, 0.714,       0.857,  0.857, 0.857, 0.857, 0.857,           1.0,    1.0,   1.0,   1.0,   1.0,       0.782,            


                                  };
                                  
final float[] Electrode_Pos_Y ={
            0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,    0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,     0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,    0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,     -0.8 ,
            0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,    0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,     0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,    0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,     -0.8 ,
           0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,    0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,     0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,    0.6 , 0.3 , 0.0 , -0.3 , -0.6 ,       -0.8 ,                     
                               };



int[] sensor_1= new int [SENSOR_DIM];
int[] sensor_2= new int [SENSOR_DIM];
int[] sensor_3= new int [SENSOR_DIM];


int[] [] sensor_mat = new int [sen_rows] [sen_cols];
int[] [] sensor2_mat = new int [sen_rows] [sen_cols];
int[] [] sensor3_mat = new int [sen_rows] [sen_cols];
int[] reducted = new int[NEW_DIM];

int[] patern_filter = new int[NEW_DIM+1];
int[] patern2_filter = new int[NEW_DIM+1];
int[] patern3_filter = new int[NEW_DIM+1];

int[] [] reducted_mat = new int [red_rows] [red_cols];
int[] [] reducted2_mat = new int [red_rows] [red_cols];
int[] [] reducted3_mat = new int [red_rows] [red_cols];

int[] [] filtered_mat = new int [red_rows] [red_cols];
int[] [] filtered2_mat = new int [red_rows] [red_cols];
int[] [] filtered3_mat = new int [red_rows] [red_cols];

float[] [] sensor_resize = new float[red_rows] [red_cols];

int i, j, a,b,c,d,  a2,b2,c2,d2, a3,b3,c3,d3;
float p_relation, rand_relation, pressure, random;
int counter;
boolean experiment2;
boolean experiment2r;


// patern 1 
                  
int[] pattern_1 ={000, 000, 000, 000, 000, 000,  
                  000, 000, 000, 000, 000, 000, 
                  000, 000, 000, 000, 000, 000, 
                  000, 000, 000, 000, 000, 000, 
                  000, 000, 000, 000, 000, 000};
                  
                  
int[] pattern_2 = {255, 255, 255, 255, 255, 255,  
                   255, 255, 255, 255, 255, 255, 
                   255, 255, 255, 255, 255, 255, 
                   255, 255, 255, 255, 255, 255, 
                   255, 255, 255, 255, 255, 255};
  
int[] pattern_3 = {255, 255, 255,   0,   0,   0,  
                   255, 255, 255,   0,   0,   0, 
                   255, 255, 255,   0,   0,   0, 
                   255, 255, 255,   0,   0,   0, 
                   255, 255, 255,   0,   0,   0};
                   
int[] pattern_4 = {  0,   0,   0, 255, 255, 255,  
                     0,   0,   0, 255, 255, 255, 
                     0,   0,   0, 255, 255, 255, 
                     0,   0,   0, 255, 255, 255, 
                     0,   0,   0, 255, 255, 255}; 
                     
int[] pattern_5 = {255, 255, 255, 255, 255, 255,  
                   255, 255, 255, 255, 255, 255, 
                   255, 255, 255, 255, 255, 255, 
                   000, 000, 000, 000, 000, 000, 
                   000, 000, 000, 000, 000, 000};
               
int[] pattern_6 = {000, 000, 000, 000, 000, 000,  
                   000, 000, 000, 000, 000, 000, 
                   000, 000, 000, 000, 000, 000,
                   255, 255, 255, 255, 255, 255, 
                   255, 255, 255, 255, 255, 255};
                  
int[] pattern_8 = {000, 000, 000, 000, 000, 000,  
                   000, 000, 000, 000, 000, 000, 
                   255, 255, 255, 255, 255, 255, 
                   000, 000, 000, 000, 000, 000,
                   000, 000, 000, 000, 000, 000};
                   
int[] pattern_7 = {000, 000, 255, 000, 000, 000,  
                   000, 000, 255, 000, 000, 000, 
                   000, 000, 255, 000, 000, 000, 
                   000, 000, 255, 000, 000, 000, 
                   000, 000, 255, 000, 000, 000};
                   
int[] pattern_9 = {255, 000, 000, 000, 000, 000,  
                   000, 255, 000, 000, 000, 000, 
                   000, 000, 255, 000, 000, 000, 
                   000, 000, 000, 255, 255, 000, 
                   000, 000, 000, 000, 255, 255};
                   
int[] pattern_10 = {000, 000, 000, 000, 255, 255,  
                    000, 000, 000, 255, 000, 000, 
                    000, 000, 255, 000, 000, 000, 
                    255, 255, 000, 000, 000, 000, 
                    255, 000, 000, 000, 000, 000};
                  
                
// thresholds
int AREASIZE_THRESHOLD=5;
int IMPEDANCE_THRESHOLD=30;
int IMPEDANCE_INITIAL_VAL = 211;

//graphical attributes
final int WINDOW_SIZE_X=800;
final int WINDOW_SIZE_Y=800;
final int WINDOW_SIZE_X_sc=1000;
final int WINDOW_SIZE_Y_sc=1000;
final int ELECTRODE_SIZE=40;

float x, y,  x1, y1, x2, y2, count=0, theta=0;
int count2=0;
color statuscolor;
int timer=0, FirstTime=0;
int[] stimulation = new int[ELECTRODE_NUM];
int[] impedance = new int[ELECTRODE_NUM];
int[] impedance_offset =  new int[ELECTRODE_NUM];
int[] impedance_diff = new int[ELECTRODE_NUM];
int[] stim_feedback_random = new int[2*ELECTRODE_NUM];


int  AreaSize;
float CoGX, CoGY, Sum;
int Volume = 0;
float factor = 0;
int factor_counter=0;
int speed = 60;
int value_radialbutton;

               
                
//send stimulation signal to ESP32
 void SendStimulationSignala()
{
  int pin;

  myPort.write((byte)PC_ESP32_STIM_PATTERN); 
  for (pin=0; pin<ELECTRODE_NUM; pin++) {
    myPort.write((byte)stimulation[pin]);
  }
  myPort.write((byte)Volume);
  if (experiment2==true) { myPort.write((byte)0); }
  else {myPort.write((byte)Factors[factor_counter]);}
}

                

void SendStimulationSignalb()
{
  int pin;

  myPort.write((byte)PC_ESP32_STIM_PATTERN); 
  for (pin=0; pin<ELECTRODE_NUM; pin++) {
    myPort.write((byte)0);
  }
  myPort.write((byte)0);
  myPort.write((byte)0);
}

                
// patern convertion to array                
void Patern_to_array() {
  for (i = 0; i < sen_cols; i++) {
    for (j = 0; j < sen_rows; j++) {
          sensor_mat[j][i] = sensor_1[i*sen_rows+j];
          sensor2_mat[j][i] = sensor_2[i*sen_rows+j];
          sensor3_mat[j][i] = sensor_3[i*sen_rows+j];
    }
  }
}

void Patern_to_array2() {
  for (int k = 0; k < number_fingers; k++){
  for (i = 0; i < sen_cols; i++) {
    for (j = 0; j < sen_rows; j++) {
          switch(k){
              case 0: sensor_mat[j][i] = data[k][i][j]; println(sensor_mat[j][i]); break;
              case 1: sensor3_mat[j][i]= data[k][i][j]; println(sensor3_mat[j][i]); break;
              case 2: sensor2_mat[j][i]= data[k][i][j]; println(sensor2_mat[j][i]); break;
          }

    }
  }
  }  
}

// transformation reduction 
void reduction_transformation() {
    for (i = 0; i < red_cols; i++) {
        for (j = 0; j < red_rows; j++) {
            a=sensor_mat[j][i];
            b=sensor_mat[j][i+1];
            c=sensor_mat[j+1][i];
            d=sensor_mat[j+1][i+1];
            
            a2=sensor2_mat[j][i];
            b2=sensor2_mat[j][i+1];
            c2=sensor2_mat[j+1][i];
            d2=sensor2_mat[j+1][i+1];
            
            a3=sensor3_mat[j][i];
            b3=sensor3_mat[j][i+1];
            c3=sensor3_mat[j+1][i];
            d3=sensor3_mat[j+1][i+1];
        
        //reducted_mat[j][i] = abs((a * d) - (c * b))/255;   // it is necesary analize how get a good comparison of the determinant
        reducted_mat[j][i] = (a+b+c+d)/4;  
        
        reducted2_mat[j][i] = (a2+b2+c2+d2)/4;
        
        reducted3_mat[j][i] = (a3+b3+c3+d3)/4;
      }
    }
 }
 
 void reduction_transformation2() {
    for (i = 0; i < red_cols; i++) {
        for (j = 0; j < red_rows; j++) {
    
        //reducted_mat[j][i] = abs((a * d) - (c * b))/255;   // it is necesary analize how get a good comparison of the determinant
        reducted_mat[j][i] = sensor_mat[j][i];  
        
        reducted2_mat[j][i] = sensor2_mat[j][i]; 
        
        reducted3_mat[j][i] = sensor3_mat[j][i]; 
      }
    }
 }
 
 

//filter matriz
void filter_array() {
for (i = 0; i < red_cols; i++) {
  for (j = 0; j < red_rows; j++) {
        pressure=reducted_mat[j][i];
        p_relation= pressure/P_max;
        rand_relation=random(0,Rand_max+1)/Rand_max;
       if (p_relation > Factors[factor_counter]*rand_relation){
       //if (p_relation > 0.6){
          filtered_mat[j][i]=255;
        }
        else{
          filtered_mat[j][i]=0;
        }
  }
}

for (i = 0; i < red_cols; i++) {
  for (j = 0; j < red_rows; j++) {
        pressure=reducted2_mat[j][i];
        p_relation= pressure/P_max;
        rand_relation=random(0,Rand_max+1)/Rand_max;
       if (p_relation > Factors[factor_counter]*rand_relation){
       //if (p_relation > 0.6){
          filtered2_mat[j][i]=255;
        }
        else{
          filtered2_mat[j][i]=0;
        }
  }
}

for (i = 0; i < red_cols; i++) {
  for (j = 0; j < red_rows; j++) {
        pressure=reducted3_mat[j][i];
        p_relation= pressure/P_max;
        rand_relation=random(0,Rand_max+1)/Rand_max;
       if (p_relation > Factors[factor_counter]*rand_relation){
       //if (p_relation > 0.6){
          filtered3_mat[j][i]=255;
        }
        else{
          filtered3_mat[j][i]=0;
        }
  }
}

}

// tranformation array to patern
void array_to_patern() {
  for (i = 0; i < red_cols; i++) {
    for (j = 0; j < red_rows; j++) {
          //patern_filter[i*red_rows+j]=filtered_mat[j][i];
          patern_filter[i*red_rows+j]=reducted_mat[j][i];
          
          //patern2_filter[i*red_rows+j]=filtered2_mat[j][i];
          patern2_filter[i*red_rows+j]=reducted2_mat[j][i];
          
          //patern3_filter[i*red_rows+j]=filtered3_mat[j][i];
          patern3_filter[i*red_rows+j]=reducted3_mat[j][i];
    }
  }
  
  
}


void matrix_generator_1(){
  int pin;
    // generator static frame for each finger
  array_to_patern();
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern3_filter[pin];
  }
  
}

void matrix_generator_2(){
  
  
  int pin;
  count2+=1;
  if (count2==speed){
    count+=1;
    count2=0;
  }
    if (count>=3) {count=0;}
  array_to_patern();
  if (count<1){
    
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern3_filter[pin];
  }
  }
  else if(count<2){
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern3_filter[pin];
  }
    
  }
 else if(count<3){
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern3_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
  }
    
  }
  
}


void matrix_generator_3(){
  
  int pin;
  
   count2+=1;
  if (count2==speed){
    count+=1;
    count2=0;
  }
    if (count==4) {count=0;}
    for (pin=0; pin<4; pin++) {
      if (pin==count){
        stimulation[5*pin+0]=255;
        stimulation[5*pin+1]=255;
        stimulation[5*pin+2]=255;
        stimulation[5*pin+3]=255;
        stimulation[5*pin+4]=255;

        stimulation[5*pin+0  +21]=255;
        stimulation[5*pin+1  +21]=255;
        stimulation[5*pin+2  +21]=255;
        stimulation[5*pin+3  +21]=255;
        stimulation[5*pin+4  +21]=255;
        
        stimulation[5*pin+0  +42]=255;
        stimulation[5*pin+1  +42]=255;
        stimulation[5*pin+2  +42]=255;
        stimulation[5*pin+3  +42]=255;
        stimulation[5*pin+4  +42]=255;
        
      }else{
        
        stimulation[5*pin+0]=0;
        stimulation[5*pin+1]=0;
        stimulation[5*pin+2]=0;
        stimulation[5*pin+3]=0;
        stimulation[5*pin+4]=0;

        stimulation[5*pin+0  +21]=0;
        stimulation[5*pin+1  +21]=0;
        stimulation[5*pin+2  +21]=0;
        stimulation[5*pin+3  +21]=0;
        stimulation[5*pin+4  +21]=0;
        
        stimulation[5*pin+0  +42]=0;
        stimulation[5*pin+1  +42]=0;
        stimulation[5*pin+2  +42]=0;
        stimulation[5*pin+3  +42]=0;
        stimulation[5*pin+4  +42]=0;
      }
    }
  
}

void matrix_generator_4(){
  
  int pin;
  
   count2+=1;
  if (count2==speed){
    count+=1;
    count2=0;
  }
    if (count==5) {count=0;}
    for (pin=0; pin<5; pin++) {
      if (pin==count){
        stimulation[pin]=255;
        stimulation[pin+5]=255;
        stimulation[pin+10]=255;
        stimulation[pin+15]=255;


        stimulation[pin+0  +21]=255;
        stimulation[pin+5  +21]=255;
        stimulation[pin+10 +21]=255;
        stimulation[pin+15 +21]=255;

        
        stimulation[pin+0  +42]=255;
        stimulation[pin+5  +42]=255;
        stimulation[pin+10 +42]=255;
        stimulation[pin+15 +42]=255;

        
      }else{
        
        stimulation[pin]=0;
        stimulation[pin+5]=0;
        stimulation[pin+10]=0;
        stimulation[pin+15]=0;


        stimulation[pin+0  +21]=0;
        stimulation[pin+5  +21]=0;
        stimulation[pin+10 +21]=0;
        stimulation[pin+15 +21]=0;

        
        stimulation[pin+0  +42]=0;
        stimulation[pin+5  +42]=0;
        stimulation[pin+10  +42]=0;
        stimulation[pin+15  +42]=0;

      }
    }   
}

void matrix_generator_5(){
  
  int pin;
  
  // rotational point generation
  //present rotating point
  x=0.2145*cos(theta)-0.6428;
  y=0.6*sin(theta);
  
  x1=0.2145*cos(theta)+0.0714;
  y1=0.6*sin(theta);
  
  x2=0.2145*cos(theta)+0.7857;
  y2=0.6*sin(theta);
//  x=0.3*cos(theta);
//  y=0.3*sin(theta);
  theta+=0.05;

//  theta+=0.5;
  for (pin=0; pin<ELECTRODE_NUM; pin++) {
    
    if (pin>0 && pin<21){
    if((x-Electrode_Pos_X[pin])*(x-Electrode_Pos_X[pin])+(y-Electrode_Pos_Y[pin])*(y-Electrode_Pos_Y[pin])<0.04){

      stimulation[pin]=255; //Pulse Height. 200 →800/1024*5= 3.91mA

    } else {
      stimulation[pin]=0;
    }
    }
    
    if (pin>21 && pin<42){
    if((x1-Electrode_Pos_X[pin])*(x1-Electrode_Pos_X[pin])+(y1-Electrode_Pos_Y[pin])*(y1-Electrode_Pos_Y[pin])<0.04){

      stimulation[pin]=255; //Pulse Height. 200 →800/1024*5= 3.91mA

    } else {
      stimulation[pin]=0;
    }
    }
    
    if (pin>42 && pin<ELECTRODE_NUM){
    if((x2-Electrode_Pos_X[pin])*(x2-Electrode_Pos_X[pin])+(y2-Electrode_Pos_Y[pin])*(y2-Electrode_Pos_Y[pin])<0.04){

      stimulation[pin]=255; //Pulse Height. 200 →800/1024*5= 3.91mA

    } else {
      stimulation[pin]=0;
    }
    }
    
  }
   
}

void matrix_generator_6(){
  
  
  int pin;
  count2+=1;
  if (count2==speed){
    count+=1;
    count2=0;
  }
    if (count>=2) {count=0;}
  array_to_patern();
  if (count<1){
    
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
  }
  
  
  
  }
  else if(count<2){
    
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
  }
  

  }
}

void matrix_generator_7(){
  
  int pin;
  count2+=1;
  if (count2==speed){
    count+=1;
    count2=0;
  }
    if (count==4) {count=0;}
  array_to_patern();
  if (count==0){
  experiment2=false;
  experiment2r=false;
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
  }
  
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
   } 
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
  } 
      
  }
  else if(count==1){
    experiment2=true;
    experiment2r=false;
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
  }
  
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
   } 
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
  }   
  }
  
 if (count==2){
  experiment2=false;
  experiment2r=false;
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
  }
  
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
   } 
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern2_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern2_filter[pin];
  } 
      
  }
  else if(count==3){
    experiment2=false;
    experiment2r=true;
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
  }
  
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
   } 
    for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern_filter[pin];
    stimulation[pin + 42]=patern_filter[pin];
  }   
  } 
}


void matrix_generator_read(){
  int pin;
    // generator static frame for each finger
  array_to_patern();
  for (pin=0; pin<20; pin++) {
    stimulation[pin]=patern_filter[pin];
    stimulation[pin + 21]=patern2_filter[pin];
    stimulation[pin + 42]=patern3_filter[pin];
  }
  
}

void recieve()
{
  if (myClient.available() > 0)
  {
    String inString = myClient.readString();
    String[] fingerData = inString.split("!");
    if (fingerData.length >= 3)
    {
      for (int f = 0; f < 3; f++)
      {
        String[] columnData = fingerData[f].split(";");
        // println(str(columnData.length)); (DEBUG)
        // println(columnData[0]); (DEBUG)
        if (columnData.length >= 5)
        {
          // println("Columns Splitted"); (DEBUG)
          columnData = subset(columnData, 1, 5);
          for (int c = 0; c < 5; c++)
          {
            String[] sensorData = columnData[c].split(":");
            if (sensorData.length >= 10)
            {
              sensorData = subset(sensorData, 1, 10);
              for (int s = 0; s < 10; s++)
              {
                //println("Finger " + str(f) + " : Column " + str(c) + " : Sensor " + str(s) + " : Data " + sensorData[s]);
                data[f][c][s] = int(sensorData[s]);
              }
            }
          }
        }
      }
    }
  }
}




void settings() {
   size(WINDOW_SIZE_X_sc,WINDOW_SIZE_Y_sc);   
   
}

PFont f,f2,f3,f4;
void setup() { 

  f = createFont("Arial",20,true);
  f2 = createFont("Ziggurat-Black",32,true);
  f3 = createFont("Ziggurat-Black",40,true);
  f4 = createFont("Arial",14,true);
  ControlFont font = new ControlFont(f);
  
  int pin, value_radialbutton;
  
  //tcp communication
   //Activate when it is necessary communication
   myClient = new Client(this, "192.168.1.189", 55555); // IP PORT

  // Open the port. baud rate=921600
  myPort = new Serial(this, COM_PORT, 921600);
  //For mac users
  //myPort = new Serial(this, "/dev/tty.usbmodem1412", 921600);
  myPort.clear();
  myPort.bufferUntil(255);
  
  
  
  cp5 = new ControlP5(this);
  
  but1= cp5.addButton("Activate")
        .setPosition(800,720)
        .setSize(160,19)
        .setValue(0)
        .setSwitch(true)
         ;
  
  
  Group g1 = cp5.addGroup("Experiments")
                .setPosition(800,200)
                .setBackgroundHeight(80)
                .setBackgroundColor(color(0,150))
                .setFont(f)
                .setBarHeight(23)
                .setSize(160,110)
                ;
                     
  r1=cp5.addRadioButton("radio")
     .setPosition(10,10)
     .setSize(20,10)
     .addItem("Static",0)
     .addItem("Basic Dinamics",1)
     .addItem("Vertical shift",2)
     .addItem("Horizontal shift",3)
     .addItem("Radial shift",4)
     .addItem("Experiment 1",5)
     .addItem("Experiment 2",6)
     .addItem("Real lecture",7)
     .setGroup(g1)
     .activate("Vertical shift")
     ;
     
             g2 = cp5.addGroup("Patterns")
                .setPosition(800,330)
                .setBackgroundHeight(80)
                .setBackgroundColor(color(0,150))
                .setFont(f)
                .setBarHeight(23)
                .setSize(160,330)
                ;
                
     cp5.addScrollableList("options")
     .setPosition(10,10)
     .setSize(130,100)
     .setBackgroundColor(color(0,200))
     .setGroup(g2)
     .addItems(java.util.Arrays.asList("F1 Empty","F1 Square","F1 Up","F1 Down","F1 Left","F1 Right","F1 Horizontal","F1 Vertical","F1 Bar Left","F1 Bar Right"))
     ;
     
     cp5.addScrollableList("options2")
     .setPosition(10,110)
     .setSize(130,100)
     .setBackgroundColor(color(0,200))
     .setGroup(g2)
     .addItems(java.util.Arrays.asList("F2 Empty","F2 Square","F2 Up","F2 Down","F2 Left","F2 Right", "F2 Horizontal","F2 Vertical","F2 Bar Left","F2 Bar Right"))
     ;
     
     cp5.addScrollableList("options3")
     .setPosition(10,220)
     .setSize(130,100)
     .setBackgroundColor(color(0,200))
     .setGroup(g2)
     .addItems(java.util.Arrays.asList("F3 Empty","F3 Square","F3 Up","F3 Down","F3 Left","F3 Right", "F3 Horizontal","F3 Vertical","F3 Bar Left","F3 Bar Right"))
     ;
     
     g3 = cp5.addGroup("Dinamics")
                .setPosition(800,330)
                .setBackgroundHeight(80)
                .setBackgroundColor(color(0,150))
                .setFont(f)
                .setBarHeight(23)
                .setSize(160,110)
                ;
  
     cp5.addScrollableList("options4")
     .setPosition(10,10)
     .setSize(130,100)
     .setBackgroundColor(color(0,200))
     .setGroup(g3)
     .addItems(java.util.Arrays.asList("Square","Up","Down","Left","Right", "Horizontal","Vertical","Bar Left","Bar Right"))
     ;
     
 /*     // add a vertical slider
     cp5.addSlider("Volume")
     .setFont(f4)
     .setPosition(800,500)
     .setSize(20,200)
     .setRange(0,200)
     .setValue(10)
     ;
  
  // reposition the Label for controller 'slider'
  cp5.getController("Volume").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
    // add a vertical slider
     cp5.addSlider("Speed")
     .setFont(f4)
     .setPosition(880,500)
     .setSize(20,200)
     .setRange(1,60)
     .setValue(1)
     ;
 // reposition the Label for controller 'slider'
  cp5.getController("Speed").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  */
  
  g2.hide();
  g3.hide();
  
  
  
  
  
  frameRate(60);  // how many time takes each iteration??
  println("Now volume is set to 0. Press UP and DOWN keys to adjust volume (max 200)");
}

//assume 60fps reflesh rate
void draw() { 
  int i, pin;
  value_radialbutton=int(r1.getValue());
  //clear screen
  background(220);
  
    
  //// data generation
  
  if (value_radialbutton==0)
  {
  //sensor_1=pattern_2;
  //sensor_2=pattern_3;
  //sensor_3=pattern_4; 
  }
  else if (value_radialbutton==1)
  {
   sensor_2=pattern_7;
   sensor_3=pattern_7;
  }
   else if (value_radialbutton==5)
  {
   sensor_2=pattern_1;
   sensor_3=pattern_1;
  }
   else if (value_radialbutton==6)
  {
   sensor_2=pattern_1;
   sensor_3=pattern_1;
  }
    
  if (value_radialbutton!=7)
  {
  Patern_to_array();
  }
  else
  {
   //activate for communication
   recieve();
   Patern_to_array2();
   
  }
  
  if (value_radialbutton!=5)
  {
  reduction_transformation();
  }
  else
  {
    reduction_transformation2();
  }
  
  switch(value_radialbutton){
    case(0): matrix_generator_1();break;
    case(1): matrix_generator_2();break;
    case(2): matrix_generator_3();break;
    case(3): matrix_generator_4();break;
    case(4): matrix_generator_5();break;
    case(5): matrix_generator_6();break;
    case(6): matrix_generator_7();break;
    case(7): matrix_generator_read();break;
  }
  
  stimulation[20]=0;
  stimulation[41]=0;
  stimulation[62]=0;
  
  if(but1.isOn()) {
     SendStimulationSignala(); }
  else {
       SendStimulationSignalb(); }

  
  
// drawing te fingers
  rect(45,30,850,65,7);
  if (experiment2== true) {fill(color(0,0,255));}
  else if (experiment2r== true) {fill(color(255,0,0));}
  else {fill(color(0,0,0));}
  rect(45,800,850,65,7);
  
  
  fill(color(255,224,191));
  stroke(255);
  strokeWeight(8);
  rect(81,155,220,492,100,100,7,7);
  rect(312,155,220,492,100,100,7,7);
  rect(544,155,220,492,100,100,7,7);
  stroke(0);
  strokeWeight(1);
  
  textFont(f3);
  fill(color(255,204,0));
  textAlign(CENTER);
  text("StimulAR ELECTRO-STIMULATION DEVICE",70+WINDOW_SIZE_X/2,80); 
  textFont(f2);       
  fill(color(200,100,100));
  textAlign(CENTER);
  text("THUMB",WINDOW_SIZE_X/4,145); 
  text("INDEX",30+WINDOW_SIZE_X/2,145); 
  text("MIDDLE",60+WINDOW_SIZE_X*3/4,145);
  fill(color(0,0,0));
  text("Volume:"+str(Volume),WINDOW_SIZE_X-600,WINDOW_SIZE_Y-60);
  fill(color(0,0,0));
  text("Factor: "+Value_Factors[factor_counter],WINDOW_SIZE_X-360,WINDOW_SIZE_Y-60);
  fill(color(0,0,0));
  text("Speed:"+str(61-speed),WINDOW_SIZE_X-150,WINDOW_SIZE_Y-60);
  fill(color(0,0,0));
  text("Original:"+str(experiment2),WINDOW_SIZE_X-150,WINDOW_SIZE_Y-20);
  
  
  //draw electrodes. Red: Stimulation, Green: Impedance (touch)
  for (pin=0; pin<ELECTRODE_NUM; pin++) {
    //statuscolor=color(stimulation[pin]*16, abs(impedance_diff[pin])*8, 100);
    statuscolor=color((stimulation[pin]*Volume)/200, 0, 100);
    fill(statuscolor);
    ellipse((Electrode_Pos_X[pin]*0.4+0.5)*WINDOW_SIZE_X,(-Electrode_Pos_Y[pin]*0.4+0.5)*WINDOW_SIZE_Y,ELECTRODE_SIZE,ELECTRODE_SIZE); 
    textFont(f);
    fill(255,255,255);
    text(pin, (Electrode_Pos_X[pin]*0.4+0.5)*WINDOW_SIZE_X,(-Electrode_Pos_Y[pin]*0.4+0.5)*WINDOW_SIZE_Y+5);
  }


}


void options(int n) {
  /* request the selected item based on index n */

  switch(n)
  {
    case(0): sensor_1=pattern_1;break;
    case(1): sensor_1=pattern_2;break;
    case(2): sensor_1=pattern_3;break;
    case(3): sensor_1=pattern_4;break;
    case(4): sensor_1=pattern_5;break;
    case(5): sensor_1=pattern_6;break;
    case(6): sensor_1=pattern_7;break;
    case(7): sensor_1=pattern_8;break;
    case(8): sensor_1=pattern_9;break;
    case(9): sensor_1=pattern_10;break;
  }
  Patern_to_array();

  reduction_transformation();


}

void options2(int n) {
  /* request the selected item based on index n */

  switch(n)
  {
    case(0): sensor_2=pattern_1;break;
    case(1): sensor_2=pattern_2;break;
    case(2): sensor_2=pattern_3;break;
    case(3): sensor_2=pattern_4;break;
    case(4): sensor_2=pattern_5;break;
    case(5): sensor_2=pattern_6;break;
    case(6): sensor_2=pattern_7;break;
    case(7): sensor_2=pattern_8;break;
    case(8): sensor_2=pattern_9;break;
    case(9): sensor_2=pattern_10;break;
  }
  Patern_to_array();

  reduction_transformation();


}

void options3(int n) {
  /* request the selected item based on index n */

  switch(n)
  {
    case(0): sensor_3=pattern_1;break;
    case(1): sensor_3=pattern_2;break;
    case(2): sensor_3=pattern_3;break;
    case(3): sensor_3=pattern_4;break;
    case(4): sensor_3=pattern_5;break;
    case(5): sensor_3=pattern_6;break;
    case(6): sensor_3=pattern_7;break;
    case(7): sensor_3=pattern_8;break;
    case(8): sensor_3=pattern_9;break;
    case(9): sensor_3=pattern_10;break;
  }
  Patern_to_array();

  reduction_transformation();

}


void options4(int n) {
  /* request the selected item based on index n */

  switch(n)
  {
    case(0): sensor_1=pattern_2;break;
    case(1): sensor_1=pattern_3;break;
    case(2): sensor_1=pattern_4;break;
    case(3): sensor_1=pattern_5;break;
    case(4): sensor_1=pattern_6;break;
    case(5): sensor_1=pattern_7;break;
    case(6): sensor_1=pattern_8;break;
    case(7): sensor_1=pattern_9;break;
    case(8): sensor_1=pattern_10;break;
  }
  Patern_to_array();
  
  if (value_radialbutton!=5)
  {
  reduction_transformation();
  }
  else
  {
    reduction_transformation2();
  }

}

void radio(int a)
{
  g2.hide();
  g3.hide();
  switch(a)
  {
    case(0): g2.show(); experiment2=false; experiment2r=false;break;
    case(1): g3.show(); experiment2=false; experiment2r=false;break;
    case(2): experiment2=false; experiment2r=false; break;
    case(3): experiment2=false; experiment2r=false; break;
    case(4): experiment2=false; experiment2r=false; break;
    case(5): g3.show(); experiment2=false; experiment2r=false; break;
    case(6): g3.show(); break;
    case(7): experiment2=false; experiment2r=false; break;
  }
}





/*
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isGroup()) {
    println("got an event from group "
            +theEvent.getGroup().getName()
            +", isOpen? "+theEvent.getGroup().isOpen()
            );
            
  } else if (theEvent.isController()){
    println("got something from a controller "
            +theEvent.getController().getName()
            );
  }
}
*/

void keyPressed() {

  
if (key == CODED) {
    if (keyCode == UP) {
      Volume = Volume + 1;
      
      
    } else if (keyCode == DOWN) {
      Volume = Volume -1;
      

    } 
   }
    else if (key == 'q') {
      
      factor_counter=factor_counter+1;
     
    } 
    
    else if (key == 'w') {
      
      factor_counter=factor_counter-1;
      
    
    } 
    
    else if (key == 's') {
      speed = speed +1;
      count2=0;
    } 
    
    else if (key == 'a') {
      speed = speed -1;
      count2=0;
    } 
  
  if(Volume > 200) Volume = 200;
  if(Volume <0) Volume = 0;
  
  
  
  if(factor_counter > 10) factor_counter = 10;
  if(factor_counter <0) factor_counter = 0;
  
  if(speed > 60) speed = 60;
  if(speed <1) speed = 1;
 
  
  //println("Volume is set to: ",speed);
  if(key == 'p'){
    myPort.write((byte)PC_ESP32_POLARITY_CHANGE); 
    println("Polarity Changed!");
  }   
}

//Serial event called when data is available
void serialEvent(Serial p) {
  int  a, inByte;
  
  p.read(); //0xFF
  for(a=0;a<2*ELECTRODE_NUM;a++){
     stim_feedback_random[a]=p.read();
     //println(stim_feedback_random[a]);
  }
  p.read();//0xFD
  
} 

/*
//println(Arrays.deepToString(sensor_mat));

println(Arrays.deepToString(sensor_mat)
    .replace("[[", "")
    .replace("], [", "\n")
    .replace("]]", "")
    .replace(" ", "  "));
    
println(Arrays.deepToString(reducted_mat)
    .replace("[[", "")
    .replace("], [", "\n")
    .replace("]]", "")
    .replace(" ", "  "));

*/

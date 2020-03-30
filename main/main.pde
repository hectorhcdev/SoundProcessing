import processing.sound.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import java.util.LinkedList;
Minim minim;
AudioOutput out;
boolean playing;
boolean pause;
boolean newNote;
int newNoteXF;
int newNoteYF;
float volumen;
boolean mute;
String status;

String [] notas={"C4","D4","E4","F4","G4","A4","B4","C5","D5","E5","F5","G5","A5"};
String [] notasBien={"Do","Re","Mi","Fa","Sol","La","Si","Do","Re","Mi","Fa","Sol","La"};;

LinkedList <int []> noteRepre;

class SineInstrument implements Instrument{
  Oscil wave;
  Line ampEnv;
  
  SineInstrument(float frequency){
    wave= new Oscil(frequency/2,0,Waves.SQUARE);
    ampEnv= new Line();
    ampEnv.patch(wave.amplitude);
  }
  
  void noteOff(){
    wave.unpatch(out);
  }
  
  void noteOn(float duration){
    ampEnv.activate(duration,0.5f,0);
    wave.patch(out);
  }
}

Pulse pulso;
float freq;
int time;

void setup(){
  size(1000,800);
  background(255);
   minim= new Minim(this);
   out=minim.getLineOut();
  noteRepre= new LinkedList();
  pulso= new Pulse(this);
  pulso.amp(0.5);
  //pulso.play();
  freq=0;
  time=0;
  playing=false;
  newNote=false;
  pause=false;
  mute=false;
  volumen=1.0;
  status="Stopped";
}

void draw(){
  //if(time>=300){
  //  if(!pulso.isPlaying()) pulso.play();
  //  pulso.freq(freq);
  //  println("eo");
  //  freq+=0.5;
  //}
  
  background(255);
  for(int i = 0; i< 6;i++){
    fill(200);
    rect(0,i*100+50,width,50);
    noFill();
  }
  for(int i=0 ; i<13; i++){
    fill(0);
    text(notasBien[i],0,i*50+25);
  }
  fill(0);
  rect(0,650,width,50);
  noFill();
  
  fill(144);
  rect(0,700,width,height-700);
  noFill();
  for(int i=0; i*120<width;i++){
    stroke(0);
    line(i*120,0,i*120,650);
    stroke(255);
    text(i*2+".0",i*120-5,698);
    line(i*120,650,i*120,685);
    for(int j=1; j<10;j++){
      line(i*120+j*12,650,i*120+j*12,660);
    }
    line(i*120+60,650,i*120+60,670);
    stroke(0);
}
  

  if(playing){
    stroke(0);
    line(time,0,time,650);
    stroke(255);
    line(time,650,time,700);
    stroke(0);
    if(!pause){
      time++;
    }
    if(time>=width){
      playing=false;
      time=0;
      status="Stopped";
    }
  }
  notesRepresentation();
  if(pause){
    fill(255,0,0);
  }else{
    fill(255);
  }
  
  rect(838,760,50,20);
  noFill();
  fill(0);
  String inst ="Intrucciones: \n  -Pausa: SPACE             -Silenciar: M\n  -Reproducir: ENTER\n  -Reiniciar: SUPR\n  -Borrar ult: LEFT";
  text(inst,50,720);
  text("NOTAS:",700,750);
  text(noteRepre.size(),750,750);
  text("MUTED:",800,750);
  text(mute+"",848,750);
  text("TIME:",800,774);
  text(time/60.0,848,774);
  noFill();
  
  if(status.equals("Playing")){
    fill(0,255,0);
    
  }else if(status.equals("Stopped")){
    fill(255,0,0);
  }else{
    fill(255);
  }
  rect(325,700,300,150);
  fill(0);
  textSize(30);
  text(status.toUpperCase(),410,755);
  textSize(11);
  noFill();
  
  if(mouseY<650){
    stroke(255,0,0);
    line(mouseX,0,mouseX,700);
    stroke(0);
  }
  
}

void notesRepresentation(){
  for(int [] i : noteRepre){
    fill(255,0,0);
    rect(i[0],i[1],i[2],i[3]);
    noFill();  
  }
}


void keyPressed(){
  if(keyCode==ENTER && !playing ){
    for(int [] i : noteRepre){
      out.playNote(((float)i[0])/60.0,((float)i[2])/60.0,new SineInstrument(Frequency.ofPitch(notas[i[1]/50]).asHz()) );
    }
    playing=true;
    time=0;
    status="Playing";
  }else if(keyCode==ENTER && playing){
    out.close();
    out=minim.getLineOut();
    playing=false;
    time=0;
    status="Stopped";
  }
  
  if(keyCode==DELETE){
    noteRepre.clear();
    out.close();
    out=minim.getLineOut();
    playing=false;
    time=0; 
  }
  
  if(keyCode==LEFT && !playing){
    
    if(!noteRepre.isEmpty()){
      noteRepre.removeLast();
    }
    
  }
  
  if(key=='m'){
    if(mute){
        out.unmute();
      }else{
        out.mute();
      }
    mute=!mute;
  }
  
  if(key==' ' && playing){
    if(pause){
      
      out.resumeNotes();
      status="Playing";
      
      pause=false;
    }else{
      out.pauseNotes();
      status="Paused";
      pause=true;
    }
    
  }
}

void mousePressed(){
  if(mouseY<650){
    if(newNote){
      fill(255,0,0);
      if(mouseX-newNoteXF<=0){
        newNote=false;
        return;
      }
      int [] aux= {newNoteXF,newNoteYF,mouseX-newNoteXF,50};
      noteRepre.addLast(aux);
    //rect(newNoteXF,newNoteYF,mouseX-newNoteXF,(int)mouseY-(int)mouseY%50);
      noFill();
      newNote=false;
    }else{
      newNoteYF=(int)mouseY-mouseY%50;
      newNoteXF=mouseX;
      newNote=true;
    }
    
  }else{
    if(mouseX>838 && mouseX<888 && mouseY>760 && mouseY<780){
      if(mute){
        out.unmute();
      }else{
        out.mute();
      }
      mute=!mute;
    }
  }
  
  //int tecla= (int)(mouseY/50);
  //if (tecla >12) return;
  //println(tecla);
  //out.playNote(0.0,0.9,new SineInstrument(Frequency.ofPitch(notas[tecla]).asHz()) );
}

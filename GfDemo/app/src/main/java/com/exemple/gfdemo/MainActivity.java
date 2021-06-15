package com.exemple.gfdemo;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

import com.exemple.gfdemo.databinding.ActivityMainBinding;

public class MainActivity extends AppCompatActivity {

  static {
    System.loadLibrary("SDL2");
    System.loadLibrary("gfcore0");
    System.loadLibrary("gf0");
    System.loadLibrary("gf-demo");
  }

  private ActivityMainBinding binding;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    binding = ActivityMainBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());

    // Example of a call to a native method
    TextView tv = binding.sampleText;
    tv.setText(stringFromJNI());
  }

  /**
   * A native method that is implemented by the 'native-lib' native library,
   * which is packaged with this application.
   */
  public native String stringFromJNI();
}
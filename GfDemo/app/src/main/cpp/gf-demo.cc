#include <jni.h>

#include <string>

#include <gf/StringUtils.h>
#include <gf/Vector.h>

extern "C" JNIEXPORT jstring JNICALL
Java_com_exemple_gfdemo_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
  auto vec = gf::vec(2, 2);
  std::string hello = "gf::niceNum: " + gf::niceNum(vec.x + vec.y / 3.0f, 0.1f);
  return env->NewStringUTF(hello.c_str());
}
import { StatusBar } from "expo-status-bar";
import { useState } from "react";
import {
  ActivityIndicator,
  Platform,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from "react-native";

const apiUrl =
  process.env.EXPO_PUBLIC_API_URL ??
  (Platform.OS === "android"
    ? "http://10.0.2.2:3001/api/v1"
    : "http://127.0.0.1:3001/api/v1");

export default function App() {
  const [state, setState] = useState<
    "idle" | "checking" | "online" | "offline"
  >("idle");
  async function checkConnection() {
    setState("checking");
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000);
    try {
      const response = await fetch(`${apiUrl}/health`, {
        signal: controller.signal,
      });
      const health = await response.json();
      if (
        !response.ok ||
        health.status !== "ok" ||
        health.database !== "up" ||
        health.mode !== "demo"
      )
        throw new Error("Unavailable");
      setState("online");
    } catch {
      setState("offline");
    } finally {
      clearTimeout(timeout);
    }
  }
  const status = {
    idle: "ยังไม่ได้ตรวจการเชื่อมต่อ",
    checking: "กำลังตรวจการเชื่อมต่อ…",
    online: "เชื่อมต่อ API และฐานข้อมูลแล้ว",
    offline: "เชื่อมต่อไม่ได้ กรุณาลองอีกครั้ง",
  }[state];
  return (
    <SafeAreaView style={styles.screen}>
      <StatusBar style="dark" />
      <View style={styles.content}>
        <View style={styles.header}>
          <Text style={styles.brand}>พร้อม</Text>
          <Text style={styles.badge}>DEMO</Text>
        </View>
        <Text style={styles.heading}>เริ่มต้นอย่างมั่นใจ</Text>
        <Text style={styles.description}>
          ระบบทดสอบสำหรับแอปสินเชื่อ{"\n"}ใช้ข้อมูลจำลองเท่านั้น
        </Text>
        <View style={styles.panel}>
          <Text style={styles.panelTitle}>ตรวจความพร้อมของระบบ</Text>
          <Text accessibilityLiveRegion="polite" style={styles.status}>
            {status}
          </Text>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="ตรวจการเชื่อมต่อระบบ"
            disabled={state === "checking"}
            onPress={checkConnection}
            style={({ pressed }) => [
              styles.button,
              (pressed || state === "checking") && styles.pressed,
            ]}
          >
            {state === "checking" ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>ตรวจการเชื่อมต่อ</Text>
            )}
          </Pressable>
        </View>
        <Text style={styles.note}>
          ยังไม่มีการสมัครสินเชื่อ ลงนาม หรือโอนเงินจริง
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: "#F6F8FA" },
  content: { padding: 24, paddingTop: 60 },
  header: {
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    marginBottom: 48,
  },
  brand: { fontSize: 30, fontWeight: "700", color: "#007F73" },
  badge: {
    color: "#007F73",
    backgroundColor: "#E5F5F1",
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    fontSize: 13,
    fontWeight: "600",
  },
  heading: {
    color: "#102044",
    fontSize: 28,
    fontWeight: "700",
    marginBottom: 12,
  },
  description: { color: "#5B6678", fontSize: 16, lineHeight: 26 },
  panel: {
    backgroundColor: "#FFF",
    padding: 24,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: "#D7DEE8",
    marginTop: 32,
  },
  panelTitle: { color: "#102044", fontSize: 19, fontWeight: "600" },
  status: {
    color: "#5B6678",
    fontSize: 16,
    lineHeight: 26,
    marginVertical: 20,
  },
  button: {
    backgroundColor: "#007F73",
    minHeight: 52,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    padding: 12,
  },
  pressed: { opacity: 0.7 },
  buttonText: { color: "#FFF", fontSize: 16, fontWeight: "600" },
  note: { marginTop: 24, color: "#5B6678", fontSize: 14, lineHeight: 24 },
});

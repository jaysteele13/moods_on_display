# 📌 Test Folder README

This folder contains various tests for the project, including **E2E**, **Integration**, and **Performance Testing**.

---

## 🏆 **Testing Overview**

| Test Type        | Automation Level | Notes |
|-----------------|-----------------|-------|
| **E2E (End-to-End)** | ✅ Fully Automated | Runs complete user flows automatically. |
| **Integration**  | 🟢 Mostly Automated | Requires manual intervention to allow **Photo Access** for Emotion Detection. |
| **Performance**  | ❌ Manual Only | Must be reviewed using **Xcode Performance Profiling** on **physical devices** while tests are running. |


---

## 🚀 **Running Automated Tests**

### **🔹 End-to-End (E2E) Tests**
Run automated **E2E** tests with, e.g.:
```sh
flutter test integration_test/E2E/login/login_test.dart
```

### **🔹 Integration Tests**
Run integration tests:
```sh
flutter test /integration_test/integration/model/detection_test.dart
```
📌 **Note:** Before running, **manually allow photo access** when prompted for Emotion Detection tests.

---

## 📊 **Performance Testing (Manual)**
Since **performance testing is manual**, follow these steps:

1. **Run the app on a physical device** (not a simulator).
   ```sh
   flutter run --release
   ```
2. **Open Xcode Instruments:**
   - Go to **Xcode > Open Developer Tool > Instruments**
   - Select **Activity Monitor** template.
   - Attach it to the running app.
3. **Monitor and Record Performance:**
   - Analyze **CPU, Memory, and GPU usage** while running tests.
   - Take screenshots or export graphs.
4. **Document Performance:**
   - Save and log results in `performance_logs/` by date.
   - Make Directory with format `p-log_DD-MM-YY`
   - Example: `performance_logs/p-log_03-12-25`
   - Include Trace which will need to be opened in XCode to View.
   - Include Description File of steps to produce performance report
   - Reference Duration and / or test used or manual test.

For a more streamlined way to test performance, we can test Model Prediction and monitor performance of three seperate datasets.
```sh
flutter test integration_test/integration/model/detection_test.dart
```
Ensure to mention which test was used in PErformance Test Description.
---

## 📂 **Folder Structure**
```
/integration_test
│── e2e/                 # End-to-End tests (Automated)
│── integration/          # Integration tests (Mostly Automated)
│── integration/performance_logs/     # Performance reports & graphs (Manual)
│── README.md            # This file
```

---

## 📌 **Additional Notes**
- Ensure **photo access** is granted manually when running **integration tests** for Model Prediction.
- Always test **performance on real devices**, not emulators.
- Update **performance logs** regularly to track improvements or regressions.



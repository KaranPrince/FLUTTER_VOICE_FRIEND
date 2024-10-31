### **Tutorial: Adding a New Voice-Guided Activity to Your Flutter Assistant Project**

This tutorial will walk you through adding a new activity to your Flutter project, enabling it to support new guided interactions in your voice assistant app.

### **Overview**
You'll need to:
1. Create a new activity in `lib/activities.dart`.
2. Add assets (images) for the new activity.
3. Update `LLMService` to recognize the new activity.
4. Create and configure a new template for the activity’s voice guidance.
5. Compile and test your changes.

---

### **Step 1: Define the New Activity in `lib/activities.dart`**

1. Open `lib/activities.dart`.
2. Define your new activity by creating an `Activity` instance with properties like `activityId`, `name`, `description`, `requiredLevel`, `category`, `displayOrder`, and `duration`.

   For example:

   ```dart
   Activity myNewActivity = Activity(
     activityId: ActivityId.myNewActivity, // New activityId
     name: "My New Activity", // Name for display
     description: 'A new interactive activity to guide the user', // Brief description
     requiredLevel: 0, // Minimum level required (set to 0 for no requirement)
     category: ActivityCategory.dreamActivities, // Define a suitable category
     displayOrder: 2, // Order of display
     duration: 7, // Duration of the activity in minutes
     imagePath: 'assets/activities/my_new_activity_image.webp', // Path to the image
   );
   ```

3. **Add the New Activity to the Activity List:**
   Update the `initializeActivities` function to include your new activity:

   ```dart
   List<Activity> initializeActivities() {
     return [
       introductionActivity,
       dreamAnalystActivity,
       myNewActivity, // Add here
     ];
   }
   ```

### **Step 2: Add an Image for Your New Activity**

1. Add an image file that represents your activity to the `assets/activities/` folder, naming it (e.g., `my_new_activity_image.webp`).
2. Confirm that the asset is accessible by adding it to your `pubspec.yaml` under the `assets` section:

   ```yaml
   flutter:
     assets:
       - assets/activities/my_new_activity_image.webp
   ```

### **Step 3: Update `LLMService` to Recognize the New Activity**

1. Open `lib/services/llm_service.dart`.
2. Locate the `updateTemplate` function, which sets the template based on the activity’s `activityId`.
3. Add a case for your new activity:

   ```dart
   void updateTemplate(Activity activity) {
     switch (activity.activityId) {
       case ActivityId.introduction:
         llmChain.setTemplate(templateIntroduction);
         break;
       case ActivityId.dreamAnalyst:
         llmChain.setTemplate(templateDreamAnalyst);
         break;
       case ActivityId.myNewActivity: // New case for your activity
         llmChain.setTemplate(templateMindfulCompanion); // Set to your template
         break;
       default:
         // Handle other cases
         break;
     }
   }
   ```

### **Step 4: Create a New Template for Your Activity**

1. **Create a Template File:**
   - In `lib/llm_templates/activities/`, create a new file, `example_my_new_activity_template.dart`.

2. **Define the Template:**
   - Here’s a sample template structure based on an assistant guide. Customize it to match your new activity’s purpose.

     ```dart
     String templateMindfulCompanion = """
     {language}

     You are Whisper, the user’s assistant for this activity. Guide the user through structured, engaging steps.
     
     1. **Start by asking the user for initial input or context related to the activity.**

     2. **Provide feedback, suggestions, or prompts based on their responses.**
     
     3. **Help the user by asking clarifying questions to keep the conversation natural.**

     ## USER DETAILS ##

     {user_information}

     ## END USER DETAILS ##

     ## SUMMARY OF PREVIOUS INTERACTIONS ##

     {session_history}

     ## END SUMMARY OF PREVIOUS INTERACTIONS ##

     ## CURRENT CONVERSATION ##

     {chat_history}

     Human: {input}
     AI: """;
     ```

3. **Update the Template Export File:**
   - Open `lib/llm_templates/all_templates.dart` and add an export statement for your new template file:

     ```dart
     export 'package:flutter_voice_friend/llm_templates/activities/example_my_new_activity_template.dart';
     ```

4. **Compile and Test the Changes:**
   - Update the list of activity IDs in `lib/models/activity.dart` by adding `myNewActivity` to the `ActivityId` enum:

     ```dart
     enum ActivityId { introduction, dreamAnalyst, myNewActivity }
     ```

   - After updating, recompile by running the following command to ensure the database and models are in sync:

     ```bash
     dart run build_runner build
     ```

---

### **Step 5: Test the New Activity in the App**

1. **Run the App:**
   Launch your Flutter app to verify that the new activity appears in the list and functions as expected.
2. **Interact with the Assistant:**
   Navigate to the activity and ensure that your assistant follows the new template for the voice-guided interaction.
3. **Check Debugging Logs:**
   If you encounter any issues, use the debug logs to verify that the activity is loading, the template is setting correctly, and the assistant is responding as expected.

---

### **Conclusion**

You’ve successfully added a new voice-guided activity to your Flutter-based assistant project! This process involved creating a new activity, adding assets, updating the logic for template selection, creating a custom activity template, and running a build to test.
# FCM Server Implementation Examples

## 🔥 Firebase Cloud Messaging Setup

Your app is now configured to receive FCM notifications from your server. Here are the payload examples for each notification type:

## 📡 Server FCM Payload Examples

### 1. General Notification
```json
{
  "to": "USER_FCM_TOKEN",
  "notification": {
    "title": "Company Announcement",
    "body": "New company policies have been updated. Please review the employee handbook."
  },
  "data": {
    "type": "general",
    "announcement_id": "123",
    "action_url": "/announcements/123"
  }
}
```

### 2. Payroll Notification
```json
{
  "to": "USER_FCM_TOKEN",
  "notification": {
    "title": "Salary Processed",
    "body": "Your salary for January has been processed and will be credited to your account."
  },
  "data": {
    "type": "payroll",
    "amount": "5000",
    "month": "January",
    "year": "2025",
    "action_url": "/payroll"
  }
}
```

### 3. Request Status Notification
```json
{
  "to": "USER_FCM_TOKEN",
  "notification": {
    "title": "Leave Request Approved",
    "body": "Your leave request for January 15-20 has been approved by your manager."
  },
  "data": {
    "type": "requestStatus",
    "request_id": "456",
    "status": "approved",
    "action_url": "/requests/456"
  }
}
```

### 4. Message Notification
```json
{
  "to": "USER_FCM_TOKEN",
  "notification": {
    "title": "New Message from HR",
    "body": "Please submit your updated documents by end of this week."
  },
  "data": {
    "type": "message",
    "sender_id": "789",
    "sender_name": "HR Department",
    "message_id": "101",
    "action_url": "/messages/101"
  }
}
```

## 🎯 Topic-Based Notifications

### Send to All Employees (General)
```json
{
  "to": "/topics/all_employees",
  "notification": {
    "title": "System Maintenance",
    "body": "The HR system will be under maintenance tonight from 10 PM to 2 AM."
  },
  "data": {
    "type": "general",
    "maintenance_id": "main_001"
  }
}
```

### Send to Department (Payroll)
```json
{
  "to": "/topics/department_finance",
  "notification": {
    "title": "Monthly Payroll Reminder",
    "body": "Please review and approve pending payroll items by EOD."
  },
  "data": {
    "type": "payroll",
    "department": "finance",
    "deadline": "2025-01-31"
  }
}
```

## 🖥️ Server Implementation Examples

### PHP Example
```php
function sendFCMNotification($userToken, $title, $body, $type, $data = []) {
    $serverKey = 'YOUR_FCM_SERVER_KEY';
    
    $payload = [
        'to' => $userToken,
        'notification' => [
            'title' => $title,
            'body' => $body,
            'sound' => 'default'
        ],
        'data' => array_merge([
            'type' => $type
        ], $data)
    ];
    
    $headers = [
        'Authorization: key=' . $serverKey,
        'Content-Type: application/json'
    ];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $result = curl_exec($ch);
    curl_close($ch);
    
    return json_decode($result, true);
}

// Usage examples:
sendFCMNotification($userToken, 'Salary Processed', 'Your January salary is ready', 'payroll', [
    'amount' => '5000',
    'month' => 'January'
]);
```

### Node.js Example
```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./path/to/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

async function sendFCMNotification(userToken, title, body, type, data = {}) {
  const message = {
    token: userToken,
    notification: {
      title: title,
      body: body
    },
    data: {
      type: type,
      ...data
    }
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.log('Error sending message:', error);
    throw error;
  }
}

// Usage examples:
await sendFCMNotification(userToken, 'Leave Request Updated', 'Your leave request status has changed', 'requestStatus', {
  request_id: '123',
  status: 'approved'
});
```

### Python Example
```python
import requests
import json

def send_fcm_notification(user_token, title, body, notification_type, data=None):
    server_key = 'YOUR_FCM_SERVER_KEY'
    
    if data is None:
        data = {}
    
    payload = {
        'to': user_token,
        'notification': {
            'title': title,
            'body': body,
            'sound': 'default'
        },
        'data': {
            'type': notification_type,
            **data
        }
    }
    
    headers = {
        'Authorization': f'key={server_key}',
        'Content-Type': 'application/json'
    }
    
    response = requests.post(
        'https://fcm.googleapis.com/fcm/send',
        headers=headers,
        data=json.dumps(payload)
    )
    
    return response.json()

# Usage examples:
send_fcm_notification(
    user_token, 
    'New Message', 
    'You have a new message from your manager', 
    'message', 
    {
        'sender_id': '456',
        'sender_name': 'John Manager',
        'message_id': '789'
    }
)
```

## 📱 App Navigation Behavior

Based on the notification type, the app will automatically navigate to:

- **General**: Opens notifications screen
- **Payroll**: Opens payroll screen (`/payroll`)
- **Request Status**: Opens request details (`/request-details`) if `request_id` provided, otherwise requests list (`/requests`)
- **Message**: Opens chat (`/chat`) if `sender_id` provided, otherwise messages list (`/messages`)

## 🔧 Testing FCM

### Test with FCM Console
1. Go to Firebase Console → Your Project → Cloud Messaging
2. Click "Send your first message"
3. Use the FCM token from your app (check debug console)
4. Add custom data fields for notification type

### Test Payloads
Use the examples above in your server code or FCM testing tools like Postman.

## 💡 Important Notes

1. **FCM Token**: The app automatically sends the FCM token during login as `fcm_id`
2. **Token Refresh**: The app automatically updates the token when it refreshes
3. **Notification Types**: Must use exact values: `general`, `payroll`, `requestStatus`, `message`
4. **Data Fields**: Include relevant IDs for navigation (request_id, sender_id, etc.)
5. **Background Processing**: FCM handles notification display automatically - no local notifications needed
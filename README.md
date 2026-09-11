# aclub2

Alpine Club Demo Project using Firebase


## Project Overview

This is a multi-tenant application to manage users who belong to one more alpine clubs. The application consists of three main components:

* Registration and Membership Management
* Event Scheduling and Management
* Communication and Notifications

## Entity Relationships (informal)

* The term Users is often used interchangeably with Members. Use the term Members in the user interface.
* Members belong to Sections
* Sections have Events
* Members can belong to more than one Section. After logging in they choose the section they want to view.
* Members can register for Events and receive Notifications for events and their registration status


### Events

* Events have attributes such as title, description, type,  start date, end date, start time, end time, location, and associated Section. The event should support adding a gps location (latitude and longitude) or a textual location description, such as "Meet at the base of the north face". Alternatively the event can have a http link to a map location.
* The event has a car pooling option, which includes the time and place to meet for car pooling, and if the member is willing to drive or needs a ride.
* Events can span multiple days. They have a start time and end time.
* Events have a minimum and maximum number of participants.
* Events can be marked as public or draft. Public events are visible to all Users, while draft events are only visible to the creator and trip leaders.
* Events can be created, updated, and deleted by authorized Members.
* Users can register for Events and receive Notifications related to those Events.* Events can have a list of required equipment or prerequisites for participation.
* Events have a waitlist feature when the maximum number of participants is reached.
* Events have a difficulty rating (e.g., easy, moderate, hard) to help Users choose appropriate activities.
* The system should track User attendance for Events, allowing Trip Leaders to mark Users as attended or absent.
* Events are of a specific type (e.g., hike, climb, alpine ski, ski mountaineering, snowshoe, social, presentation).
* Some events may allow direct registration. Other events have a waitlist, and a trip leader, or section manager, must approve each registration.
* When created an event should initially be in draft. The event manager should be able to publish an event. Show the draft/publish on the event edit screen.   Draft events should not show up on the event list. Only when the user selects "my events" and they an event manager for the event should they

## Templates

* Rather than create different event attributes such as required equipment, risks, etc, the sytem will support markdown templates.
* An admin can create templates. A template has a languate (en or fr) and markdown text
* When an event is created or edited, the editor can select a template to insert into the event description field, or any other field that accepts markdown.

### Members

* Member Info is in addition to the User information that comes from authentication.
* Members can have profile pictures and personal information (e.g., emergency contact details, medical conditions).
* Emergency contact details are mandatory fields.
* Members have certifications and skills associated with their profiles (e.g., first aid certification, climbing experience, AST 2, etc.). This information can be text.
* Members can belong to multiple Sections.
* Members can register for Events and receive Notifications.

### Sections

* Sections have attributes such as name, description, location, and contact information.
* Sections can host multiple Events.
* Sections can have multiple Section Managers assigned to them.
* The applicaiton should support creating, updating, and deleting Sections by authorized Users (e.g., Admins).
* Section membersship is managed by an external system. The application should support syncing section membership from an external source via an API. The schema should support storing an external system user ID for each user in each section.


### Notifications

* Notifications have attributes such as title, message, timestamp, application link,and recipient User.
* Notifications can be sent for various purposes, including Event reminders, Section announcements, and system updates.
* Notifications can be marked as read or unread by Users.
* Notifications can be sent via multiple channels including push notifications, email and in-app notifications.
* Users can customize their notification preferences (e.g., frequency, channels).


## Role Based Access Control (RBAC)

* Admins: Full access to all features and data.
* Section Managers: Can manage Users and Events within their Sections. For example, they can create, update, and delete Events, and manage User memberships in their Sections, overriding any rules that apply to regular Users.
* Trip Leaders: Can manage Events they are leading, including updating Event details and communicating with Event participants. A trip leader can delete an event that they have created.
* Members: Can view and register for Events, and receive Notifications. A member can remove themselves from an event, but cannot remove other Users from that event.
* Guests: Limited access to view public Events and Sections. Guests cannot register for Events or receive Notifications. However, a member can add a guest to an event they are attending. The schema should support this use case.
* Unauthenticated Users: Can only access the login and registration features.

## Implementation Details

Uses the following Flutter packages

* Routing using kaisel router
* State management using signals and BlocSignals
* Models are defined using Freezed
* Firebase is used for authentication
* Firestore is the database

---

## Firestore Schema

### Collection Hierarchy

```
/users/{userId}
/sections/{sectionId}
/sections/{sectionId}/members/{userId}
/sections/{sectionId}/events/{eventId}
/sections/{sectionId}/events/{eventId}/registrations/{registrationId}
/notifications/{notificationId}
/templates/{templateId}
```

> **Note on document IDs:** `userId` always matches the Firebase Auth UID.
> Section managers are **not** a global role — they are tracked per section via the `managerIds` field on each `/sections/{sectionId}` document.

---

### `/users/{userId}`

Stores member profile data beyond what Firebase Auth provides.

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firebase Auth UID (same as document ID) |
| `displayName` | `String` | ✓ | |
| `email` | `String` | ✓ | |
| `photoUrl` | `String` | | Profile picture URL |
| `phone` | `String` | | |
| `emergencyContactName` | `String` | ✓ | Mandatory |
| `emergencyContactPhone` | `String` | ✓ | Mandatory |
| `emergencyContactRelation` | `String` | | e.g. "Spouse", "Parent" |
| `medicalConditions` | `String` | | |
| `certifications` | `String[]` | | e.g. `["First Aid", "AST 2"]` |
| `sectionIds` | `String[]` | | IDs of sections the user belongs to |
| `role` | `String` (enum) | ✓ | `admin` \| `tripLeader` \| `member` \| `guest` |
| `notificationPreferences` | `Map` (embedded) | ✓ | See below |
| `createdAt` | `Timestamp` | ✓ | |
| `updatedAt` | `Timestamp` | ✓ | |

**Embedded: `notificationPreferences`**

| Field | Type | Default | Notes |
|---|---|---|---|
| `pushEnabled` | `Boolean` | `true` | |
| `emailEnabled` | `Boolean` | `true` | |
| `inAppEnabled` | `Boolean` | `true` | |
| `frequency` | `String` (enum) | `immediate` | `immediate` \| `daily` \| `weekly` |

---

### `/sections/{sectionId}`

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `name` | `String` | ✓ | |
| `description` | `String` | | |
| `location` | `String` | | Region or city, e.g. "Vancouver, BC" |
| `contactEmail` | `String` | | |
| `contactPhone` | `String` | | |
| `managerIds` | `String[]` | | User IDs with manager rights for this section only |
| `createdAt` | `Timestamp` | ✓ | |
| `updatedAt` | `Timestamp` | ✓ | |

---

### `/sections/{sectionId}/members/{userId}`

Join record linking a user to a section. Supports external system membership sync.

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `userId` | `String` | ✓ | Same as document ID |
| `sectionId` | `String` | ✓ | Parent section ID |
| `externalSystemId` | `String` | | ID from external membership system |
| `joinedAt` | `Timestamp` | ✓ | |

---

### `/sections/{sectionId}/events/{eventId}`

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `sectionId` | `String` | ✓ | Denormalised for queries |
| `title` | `String` | ✓ | |
| `description` | `String` | | Markdown. Templates can be inserted here. |
| `type` | `String` (enum) | ✓ | `hike` \| `climb` \| `alpineSki` \| `skiMountaineering` \| `snowshoe` \| `social` \| `presentation` |
| `status` | `String` (enum) | ✓ | `draft` \| `published`. New events default to `draft`. |
| `startDate` | `Timestamp` | ✓ | Events can span multiple days |
| `endDate` | `Timestamp` | ✓ | |
| `location` | `Map` (embedded) | | See below |
| `carpoolOption` | `Map` (embedded) | | See below; `null` if carpooling not offered |
| `minParticipants` | `Number` | ✓ | Default `0` |
| `maxParticipants` | `Number` | ✓ | When reached, new registrations go to waitlist |
| `difficulty` | `String` (enum) | ✓ | `easy` \| `moderate` \| `hard` |
| `requiresApproval` | `Boolean` | ✓ | `false` = direct registration; `true` = leader/manager approval required |
| `requiredEquipment` | `String[]` | | Free text or markdown items |
| `prerequisites` | `String[]` | | Free text or markdown items |
| `creatorId` | `String` | ✓ | User ID of creator |
| `tripLeaderIds` | `String[]` | | User IDs of trip leaders |
| `createdAt` | `Timestamp` | ✓ | |
| `updatedAt` | `Timestamp` | ✓ | |

**Embedded: `location`**

| Field | Type | Notes |
|---|---|---|
| `description` | `String` | e.g. "Meet at the base of the north face" |
| `latitude` | `Number` | GPS decimal degrees |
| `longitude` | `Number` | GPS decimal degrees |
| `mapUrl` | `String` | HTTP link to map (e.g. Google Maps, CalTopo) |

At least one of `description`, GPS (`latitude` + `longitude`), or `mapUrl` should be set.

**Embedded: `carpoolOption`**

| Field | Type | Notes |
|---|---|---|
| `meetTime` | `Timestamp` | Date and time to meet for carpooling |
| `meetPlace` | `String` | e.g. "Park & Ride on Hwy 1" |

---

### `/sections/{sectionId}/events/{eventId}/registrations/{registrationId}`

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `userId` | `String` | ✓ | Registering member's user ID |
| `guestName` | `String` | | Set when a member registers a guest (no user account required) |
| `status` | `String` (enum) | ✓ | `pending` \| `approved` \| `waitlisted` \| `rejected` \| `attended` \| `absent` |
| `isDriver` | `Boolean` | | Carpool: member is willing to drive |
| `needsRide` | `Boolean` | | Carpool: member needs a ride |
| `registeredAt` | `Timestamp` | ✓ | |
| `updatedAt` | `Timestamp` | ✓ | Updated when status changes (e.g. attendance marked) |

---

### `/notifications/{notificationId}`

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `recipientId` | `String` | ✓ | User ID of the recipient |
| `title` | `String` | ✓ | |
| `message` | `String` | ✓ | |
| `link` | `String` | | Deep-link or in-app route, e.g. `/events/abc123` |
| `channels` | `String[]` (enum) | | `push` \| `email` \| `inApp` |
| `isRead` | `Boolean` | ✓ | Default `false` |
| `relatedEventId` | `String` | | Optional reference to a related event |
| `relatedSectionId` | `String` | | Optional reference to a related section |
| `createdAt` | `Timestamp` | ✓ | |

---

### `/templates/{templateId}`

Admin-managed markdown templates that can be inserted into event description fields.

| Field | Type | Required | Notes |
|---|---|:---:|---|
| `id` | `String` | ✓ | Firestore document ID |
| `language` | `String` | ✓ | ISO code: `en` or `fr` |
| `title` | `String` | ✓ | Admin-visible name for the template |
| `markdownText` | `String` | ✓ | The full markdown body |
| `createdBy` | `String` | ✓ | User ID of the admin who created it |
| `createdAt` | `Timestamp` | ✓ | |
| `updatedAt` | `Timestamp` | ✓ | |

---

### Enums Reference

| Enum | Values |
|---|---|
| `UserRole` | `admin`, `tripLeader`, `member`, `guest` |
| `EventType` | `hike`, `climb`, `alpineSki`, `skiMountaineering`, `snowshoe`, `social`, `presentation` |
| `EventStatus` | `draft`, `published` |
| `Difficulty` | `easy`, `moderate`, `hard` |
| `RegistrationStatus` | `pending`, `approved`, `waitlisted`, `rejected`, `attended`, `absent` |
| `NotificationChannel` | `push`, `email`, `inApp` |
| `NotificationFrequency` | `immediate`, `daily`, `weekly` |


### TODO:

* UI Actions like edit event should be disabled for users who do not have the tripLeader or sectionAdmin roles.
* Create a MyEvents filter. That shows events that I am registered for or that I have created or am a trip leader for.


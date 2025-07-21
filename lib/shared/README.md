# Shared Systems

This directory contains reusable, abstracted code systems that can be easily ported to different app projects. These systems follow clean architecture principles and provide consistent, maintainable solutions.

## 📁 Structure

```
shared/
├── theme/          # Theme and styling system
├── notifications/  # Notification and messaging system
├── widgets/        # Reusable UI components
└── utils/          # Utility functions and helpers
```

## 🎯 Design Principles

1. **Abstraction**: Systems are designed to be app-agnostic
2. **Consistency**: Unified APIs and patterns across systems
3. **Maintainability**: Clean code with proper separation of concerns
4. **Reusability**: Easy to extract and use in different projects
5. **Testability**: Well-defined interfaces for testing

## 🚀 Systems Overview

### Theme System
- **Abstract theme interfaces** for consistent styling
- **Color palette management** with runtime switching
- **Component theming** with automatic adaptation
- **Preference persistence** with SharedPreferences

### Notification System
- **Type-safe notification configs** with consistent behavior
- **Smooth animations** with configurable timing
- **Global state management** preventing notification conflicts
- **Easy-to-use APIs** with context extensions

### Widget System
- **Reusable UI components** following Material Design
- **Consistent animations** across all interactive elements
- **Proper accessibility** support built-in
- **Responsive design** adaptation

### Utils System
- **Common utility functions** for data manipulation
- **Validation helpers** for user input
- **Extension methods** for better DX
- **Type-safe helpers** for common operations

## 🔧 Usage

Each system is designed to be self-contained and can be easily copied to new projects. Simply:

1. Copy the relevant system folder(s)
2. Update import paths as needed
3. Implement any app-specific configurations
4. Enjoy consistent, maintainable code!

## 📋 Integration Checklist

When integrating these systems into a new project:

- [ ] Update package dependencies
- [ ] Configure app-specific colors/themes
- [ ] Set up proper error handling
- [ ] Add any custom notification types
- [ ] Configure persistence preferences
- [ ] Test all system integrations

## 🎨 Customization

Each system provides clear extension points:

- **Theme**: Extend `ColorPalette` and `ThemeConfig`
- **Notifications**: Create custom `NotificationConfig` types
- **Widgets**: Extend base components with app-specific styling
- **Utils**: Add domain-specific utility functions

## 🧪 Testing

All systems include proper interfaces for testing:

- **Theme**: Mock theme controllers and color providers
- **Notifications**: Test notification manager state
- **Widgets**: Unit test component behavior
- **Utils**: Test utility function outputs

---

*Built with ❤️ for maximum reusability and maintainability*
# Design Review Process

## Human-in-the-Loop Design Reviews

For any UI/UX changes, ALWAYS request human review before considering the design complete.

### When to Request Design Review

1. **New UI components or pages**
2. **Significant layout changes**
3. **User flow modifications**
4. **Accessibility implementations**
5. **Responsive design updates**
6. **Color/styling changes**

### Design Review Checklist

Before requesting review, Claude should:

#### ✅ Technical Implementation
- [ ] All functionality working correctly
- [ ] Tests passing
- [ ] No console errors
- [ ] Responsive design implemented
- [ ] Accessibility features added

#### ✅ Visual Design
- [ ] Layout is properly centered/positioned
- [ ] Consistent with existing design system
- [ ] Proper spacing and typography
- [ ] Mobile-friendly design
- [ ] Loading states implemented

#### ✅ User Experience
- [ ] Clear navigation flow
- [ ] Intuitive form interactions
- [ ] Helpful error messages
- [ ] Appropriate feedback to users
- [ ] No confusing UI elements

### Review Request Template

When requesting review, Claude should ask:

> **🎨 Design Review Needed**
> 
> I've implemented [feature/page/component]. Before finalizing, could you please review:
> 
> **What to check:**
> - [ ] Overall layout and centering
> - [ ] Visual design consistency
> - [ ] Mobile responsiveness
> - [ ] User flow intuitiveness
> - [ ] Any visual issues or improvements
> 
> **Test URLs:**
> - Main feature: [URL]
> - Mobile view: [URL] (resize browser)
> - Edge cases: [URLs if applicable]
> 
> **Key concerns to validate:**
> - [Specific items user should focus on]
> 
> Please let me know if the design looks good or if you'd like any adjustments!

### Post-Review Actions

After receiving feedback:
1. **Implement all requested changes**
2. **Test changes thoroughly**
3. **Request follow-up review if major changes made**
4. **Document any design decisions for future reference**

### Design Principles to Follow

1. **Centering & Layout**: Ensure proper positioning, especially on authentication pages
2. **Sidebar Logic**: Hide sidebar on standalone pages (auth, errors, etc.)
3. **Consistency**: Match existing design patterns and spacing
4. **Accessibility**: Always include proper ARIA labels and semantic HTML
5. **Mobile-First**: Design for mobile, enhance for desktop
6. **Loading States**: Provide clear feedback during user actions


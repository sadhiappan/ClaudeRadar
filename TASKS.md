# TASKS.md - ClaudeRadar UI Redesign Implementation

## Overview
Complete UI redesign based on the provided mockup with model-specific data, dark/light mode support, accessibility features, and comprehensive TDD approach.

## Task Breakdown

### Phase 1: Foundation & Data Model (TDD Required)

#### Task 1: Model Data Structure ✅
**Objective**: Add model tracking to sessions and create model information system
- [x] Add model tracking to `ClaudeSession` (`models: [String: Int]`)  
- [x] Create `ModelInfo` struct with specs for Opus/Sonnet/Haiku
- [x] Update `SessionCalculator` to aggregate usage by model
- [x] Write comprehensive tests for model aggregation logic
- [x] Test edge cases: unknown models, mixed sessions, empty data

**Acceptance Criteria**:
- Sessions track token usage per model
- Model info provides display names, colors, limits
- Tests cover all aggregation scenarios
- Backward compatibility maintained

#### Task 2: Theme System Foundation ✅
**Objective**: Implement comprehensive dark/light mode system
- [x] Create `ThemeManager` with automatic system detection
- [x] Implement color system matching mockup specifications
- [x] Add theme persistence and switching logic
- [x] Test theme transitions and system appearance changes

**Acceptance Criteria**:
- Automatic theme switching based on system appearance
- All colors defined semantically (background, text, accent)
- Smooth transitions between themes
- Tests for theme state management

### Phase 2: Core UI Components (TDD Required)

#### Task 3: Typography & Spacing System ✅
**Objective**: Implement design system foundation
- [x] Create semantic typography scale matching design specs
- [x] Implement 4px/8px/16px spacing grid system
- [x] Build reusable layout components with precise measurements
- [x] Test typography scaling and spacing consistency

**Acceptance Criteria**:
- Typography matches mockup specifications exactly
- Consistent spacing throughout interface
- Responsive to Dynamic Type settings
- Tests for typography and spacing components

#### Task 4: Progress Bar Components ✅
**Objective**: Build animated, accessible progress indicators
- [x] Create `ModelProgressBar` component with smooth animations
- [x] Implement color-coded progress indicators by model
- [x] Add comprehensive accessibility labels
- [x] Test progress calculations and visual states

**Acceptance Criteria**:
- Progress bars animate smoothly (0.3s ease-out)
- Model-specific colors (Opus=red, Sonnet=blue, Haiku=green)
- Full screen reader support
- Tests for progress logic and accessibility

### Phase 3: New UI Layout (TDD Required)

#### Task 5: Header Section Redesign ✅
**Objective**: Implement new header with gradient and status
- [x] Create gradient background header (44px height)
- [x] Add green status indicator and app title
- [x] Implement location display ("pro | Europe/Warsaw")
- [x] Test header with various text lengths and states

**Acceptance Criteria**:
- Exact match to mockup design
- Responsive text handling
- Proper status indicator states
- Tests for header components

#### Task 6: Models Section Implementation ✅
**Objective**: Build core models breakdown visualization
- [x] Create models section with "MODELS" header
- [x] Implement 3 model progress rows (Opus, Sonnet, Haiku)
- [x] Add percentage displays and proper spacing
- [x] Test with various model usage combinations

**Acceptance Criteria**:
- Model rows show: name + progress bar + percentage
- Color coding matches design (red/blue/green)
- Proper spacing and alignment
- Tests for model data display

#### Task 7: Footer Section ✅
**Objective**: Redesign footer with time and status
- [x] Implement footer with time display and session status
- [x] Add status indicators with appropriate colors
- [x] Create responsive footer layout
- [x] Test footer states (connected/disconnected/no session)

**Acceptance Criteria**:
- Time display with clock icon
- Session status with colored indicator
- Proper background and borders
- Tests for footer states

### Phase 4: Accessibility & Polish (TDD Required)

#### Task 8: Accessibility Implementation 📋
**Objective**: Full WCAG 2.1 AA compliance
- [ ] Implement Dynamic Type support for all text
- [ ] Add comprehensive screen reader labels
- [ ] Create keyboard navigation support
- [ ] Test with VoiceOver and accessibility inspector

**Acceptance Criteria**:
- All interactive elements keyboard accessible
- Screen reader announces all information clearly
- Supports system accessibility settings
- Tests for accessibility features

#### Task 9: Animation System 📋
**Objective**: Smooth micro-interactions and loading states
- [ ] Implement progress bar animations (0.3s ease-out)
- [ ] Add hover interactions and state changes
- [ ] Create loading states with shimmer effects
- [ ] Test animations with reduced motion preferences

**Acceptance Criteria**:
- 60fps smooth animations
- Respects prefers-reduced-motion
- Loading states provide clear feedback
- Tests for animation behavior

#### Task 10: Responsive Design 📋
**Objective**: Ensure design works in all scenarios
- [ ] Verify 280px width constraint compliance
- [ ] Test with various content lengths and edge cases
- [ ] Ensure compatibility with different system settings
- [ ] Test edge cases (no data, single model, errors)

**Acceptance Criteria**:
- Layout stable at 280px width
- Graceful handling of edge cases
- Works with all system configurations
- Comprehensive edge case tests

## Testing Requirements

### Test Coverage Targets
- **Unit Tests**: >90% coverage for all data logic
- **UI Tests**: All components and interactions
- **Integration Tests**: Theme switching and data flow
- **Accessibility Tests**: VoiceOver and keyboard navigation
- **Visual Tests**: Screenshot comparisons for design accuracy

### Test Categories
1. **Model Data Tests**: Aggregation, calculations, edge cases
2. **Theme Tests**: Switching, persistence, system detection  
3. **Component Tests**: Rendering, props, state changes
4. **Accessibility Tests**: Labels, navigation, screen readers
5. **Animation Tests**: Timing, reduced motion, performance
6. **Layout Tests**: Responsive behavior, edge cases

## Success Criteria

✅ **Visual Fidelity**: Pixel-perfect match to provided mockup  
✅ **Accessibility**: WCAG 2.1 AA compliance verified  
✅ **Performance**: Smooth 60fps animations  
✅ **Testing**: >90% test coverage with comprehensive scenarios  
✅ **Data Accuracy**: Works with real Claude usage data  
✅ **Robustness**: Proper error handling and edge cases  

## Implementation Notes

- **TDD Approach**: Write tests first, then implement features
- **Pause Protocol**: If any task becomes blocked, stop and reassess
- **Design Fidelity**: Mockup is the source of truth for visual design
- **Accessibility First**: Consider screen readers and keyboard users in every component
- **Real Data**: Test with actual Claude usage patterns and edge cases

---

**Next Steps**: Begin with Task 1 (Model Data Structure) following TDD methodology.
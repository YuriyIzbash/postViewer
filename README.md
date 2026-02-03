# Post Viewer
iOS app for viewing posts.
## Architecture: MVVM-C + UIKit
- **MVVM**: ViewModels handle state/logic; closures for binding.
- **Coordinator**: Handles navigation.
- **Programmatic UI**: Auto Layout without Storyboards.
- **DiffableDataSource**: For collection view updates.
## Structure
- `App`: Delegates & Coordinator
- `Presentation`: UI (Feed, Details)
- `Services`: Networking & Image Loading
- `Models`: Data entities

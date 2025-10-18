# Contributing to Game Catalogue

Thank you for your interest in contributing to the Game Catalogue project! This guide will help you add new games and customize the application.

## Adding New Games

### Step 1: Edit games-config.json

Add a new game entry to the `games` array in `games-config.json`:

```json
{
  "id": "your-game-id",
  "title": "Your Game Title",
  "description": "A brief description of the game that will appear on the card",
  "coverImage": "https://example.com/cover-image.jpg",
  "installCommand": "echo 'Installing Your Game...' && sleep 2 && echo 'Done!'"
}
```

### Required Fields

- **id**: Unique identifier (lowercase, hyphens for spaces)
- **title**: Display name of the game
- **description**: Brief description (1-2 sentences recommended)
- **coverImage**: URL to cover image (recommended size: 400x300px)
- **installCommand**: Shell command to execute for installation

### Step 2: Choose an Installation Method

#### Option 1: Simple Echo Command (for testing)
```json
"installCommand": "echo 'Installing Game...' && sleep 3 && echo 'Game installed!'"
```

#### Option 2: Custom Shell Script
```json
"installCommand": "./scripts/example-install.sh --game-id your-game --game-name 'Your Game' --version 1.0.0"
```

#### Option 3: Package Manager
```json
"installCommand": "apt-get update && apt-get install -y your-game-package"
```

#### Option 4: Download and Install
```json
"installCommand": "wget https://example.com/game.tar.gz && tar -xzf game.tar.gz && ./game/install.sh"
```

### Step 3: Test Your Addition

1. Save the changes to `games-config.json`
2. Restart the development server: `npm run dev`
3. Navigate to http://localhost:3000
4. Find your new game card
5. Test the installation by clicking the Install button

## Creating Custom Install Scripts

### Example Script Structure

See `scripts/example-install.sh` for a template. Key points:

1. **Shebang**: Start with `#!/bin/bash`
2. **Error Handling**: Exit with non-zero code on failure
3. **Progress Messages**: Echo status updates for user feedback
4. **Validation**: Check required parameters
5. **Make Executable**: `chmod +x your-script.sh`

### Best Practices

- ✅ **CRITICAL**: Script must wait for installation to fully complete before exiting
- ✅ Print clear status messages
- ✅ Handle errors gracefully
- ✅ Set appropriate timeouts (default is 30 minutes)
- ✅ Test scripts independently before adding to config
- ✅ Use absolute paths when possible
- ✅ Validate all inputs
- ✅ If spawning background processes, wait for them with `wait $PID`

### Critical: Installation Completion

**Your install script MUST NOT exit until the installation is completely finished.**

❌ **WRONG** - Script exits while installer runs in background:
```bash
#!/bin/bash
./game-installer.exe /SILENT &
exit 0  # Returns immediately!
```

✅ **CORRECT** - Script waits for completion:
```bash
#!/bin/bash
./game-installer.exe /SILENT
exit $?  # Returns only after installer completes
```

✅ **CORRECT** - For background processes:
```bash
#!/bin/bash
./launcher.exe &
PID=$!
wait $PID  # Wait for background process
exit $?
```

If your installer tool spawns background processes, you must monitor them:
```bash
#!/bin/bash
xvfb-run game-installer.exe &
INSTALLER_PID=$!

# Wait for actual completion
while ps -p $INSTALLER_PID > /dev/null 2>&1; do
    sleep 1
done

exit 0
```

## Security Considerations

### Important Security Notes

1. **Trusted Commands Only**: Only add install commands you trust
2. **No User Input**: Commands are taken from config file, not user input
3. **Limit Permissions**: Run the application with minimal required permissions
4. **Review Scripts**: Always review scripts before adding them
5. **Path Safety**: Use absolute paths to prevent PATH hijacking

### What NOT to Do

❌ Don't allow user-provided commands
❌ Don't run as root/administrator unless absolutely necessary
❌ Don't download and execute arbitrary code without verification
❌ Don't include sensitive credentials in commands

## Cover Images

### Recommended Specifications

- **Format**: JPEG or PNG
- **Size**: 400x300 pixels (4:3 aspect ratio)
- **File Size**: < 200KB for faster loading
- **Hosting**: Use reliable image hosting or include in `public/images/`

### Using Local Images

1. Place image in `public/images/` folder
2. Reference in config: `"coverImage": "/images/your-game.jpg"`

### Finding Images

- Use game official websites
- Stock photo sites (ensure proper licensing)
- Screenshot from gameplay (check copyright)

## Styling Customization

### Modifying Card Appearance

Edit `components/GameCard.tsx` to customize:
- Hover effects
- Button styles
- Status indicators
- Card layout

### Changing Theme Colors

Edit `app/globals.css`:
```css
:root {
  --background: #030712;  /* Main background */
  --foreground: #f9fafb;  /* Text color */
}
```

### Tailwind Configuration

Tailwind CSS v4 uses CSS-based configuration. Add custom utilities in `app/globals.css`.

## Testing

### Manual Testing Checklist

- [ ] Game card displays correctly
- [ ] Cover image loads properly
- [ ] Hover effect shows install button
- [ ] Install button triggers installation
- [ ] Status changes to "Installing..." with spinner
- [ ] Status changes to "Installed" with checkmark on success
- [ ] Success message appears at bottom of card
- [ ] Install command executes correctly (check terminal logs)
- [ ] Multiple games can be installed simultaneously
- [ ] Page remains responsive during installation

### Command Testing

Test your install command independently:
```bash
# Run the command directly in terminal
your-install-command

# Check exit code
echo $?  # Should be 0 for success
```

## Troubleshooting

### Common Issues

**Game card doesn't appear**
- Check JSON syntax in games-config.json
- Restart dev server
- Check browser console for errors

**Image doesn't load**
- Verify image URL is accessible
- Check for CORS issues with external images
- Try using a local image instead

**Install command fails**
- Test command in terminal first
- Check file permissions for scripts
- Verify all required tools are installed
- Check timeout settings (default 30s)

**Changes not reflected**
- Hard refresh browser (Ctrl+F5 or Cmd+Shift+R)
- Clear Next.js cache: `rm -rf .next`
- Restart dev server

## Pull Request Guidelines

When submitting a PR to add games:

1. Add meaningful games (not test entries)
2. Ensure install commands are safe and tested
3. Use high-quality cover images
4. Write clear descriptions
5. Test thoroughly before submitting
6. Document any new dependencies

## Questions?

For questions or issues, please open a GitHub issue with:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs or error messages

Thank you for contributing! 🎮

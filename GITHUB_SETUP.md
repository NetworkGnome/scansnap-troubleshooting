# Publishing to GitHub - Step by Step Instructions

## Prerequisites
- GitHub account
- Git installed on your computer
- SSH key configured with GitHub (or use HTTPS with personal access token)

## Step 1: Create a New Repository on GitHub

1. Go to https://github.com and sign in
2. Click the **"+"** button in the top right → **"New repository"**
3. Fill in the details:
   - **Repository name**: `scansnap-troubleshooting` (or your preferred name)
   - **Description**: "Network troubleshooting toolkit for Fujitsu ScanSnap iX1600 scanners"
   - **Visibility**: Public (or Private if you prefer)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
4. Click **"Create repository"**

## Step 2: Copy the Repository to Your Machine

If you haven't already, copy the repository folder to your local machine:

```bash
# Copy from the outputs or download from Claude
# Extract if it's a zip/tar file
cd ~/Downloads
tar -xzf scansnap-troubleshooting.tar.gz
cd scansnap-troubleshooting
```

## Step 3: Configure Git (if not already done)

```bash
# Set your name and email (one time setup)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify the repo is initialized
git status
```

## Step 4: Connect to GitHub

Replace `YOUR-USERNAME` with your actual GitHub username:

### Option A: Using SSH (Recommended)
```bash
git remote add origin git@github.com:YOUR-USERNAME/scansnap-troubleshooting.git
```

### Option B: Using HTTPS
```bash
git remote add origin https://github.com/YOUR-USERNAME/scansnap-troubleshooting.git
```

## Step 5: Push to GitHub

```bash
# Verify remote is set
git remote -v

# Push to GitHub
git push -u origin main
```

If using HTTPS, you'll be prompted for your GitHub credentials. Use a [Personal Access Token](https://github.com/settings/tokens) instead of your password.

## Step 6: Verify on GitHub

1. Go to `https://github.com/YOUR-USERNAME/scansnap-troubleshooting`
2. You should see all files and the README displayed
3. Check that the repository looks correct

## Step 7: Add Topics (Optional but Recommended)

On your GitHub repository page:
1. Click the ⚙️ (gear icon) next to "About"
2. Add topics like:
   - `scansnap`
   - `fujitsu`
   - `networking`
   - `troubleshooting`
   - `diagnostics`
   - `unix`
   - `scanner`
   - `ix1600`
3. Click "Save changes"

## Step 8: Enable Issues and Discussions (Optional)

1. Go to **Settings** tab
2. Scroll to **Features** section
3. Check ✅ **Issues**
4. Check ✅ **Discussions** (if you want community discussions)

## Future Updates

When you make changes to the repository:

```bash
# Check what changed
git status

# Stage changes
git add .

# Commit with a message
git commit -m "Add new feature or fix issue"

# Push to GitHub
git push
```

## Creating Releases

When you want to tag a version:

```bash
# Create a tag
git tag -a v1.0.0 -m "Version 1.0.0 - Initial release"

# Push the tag
git push origin v1.0.0
```

Then on GitHub:
1. Go to **Releases** → **Draft a new release**
2. Select the tag you just created
3. Add release notes (copy from CHANGELOG.md)
4. Click **Publish release**

## Clone URL for Users

Once published, users can clone with:

```bash
git clone https://github.com/YOUR-USERNAME/scansnap-troubleshooting.git
```

## Updating README Links

Don't forget to update the README.md with your actual GitHub username:

```bash
# Replace YOUR-USERNAME in README.md
sed -i '' 's/YOUR-USERNAME/actual-username/g' README.md

# Commit the change
git add README.md
git commit -m "Update README with actual GitHub username"
git push
```

## Add a GitHub Actions Badge (Optional)

You can add status badges to your README to show build status, latest release, etc.

Example badges:
```markdown
![GitHub release](https://img.shields.io/github/v/release/YOUR-USERNAME/scansnap-troubleshooting)
![GitHub issues](https://img.shields.io/github/issues/YOUR-USERNAME/scansnap-troubleshooting)
![License](https://img.shields.io/github/license/YOUR-USERNAME/scansnap-troubleshooting)
```

## Troubleshooting

### Authentication Failed
If you get authentication errors:
- For HTTPS: Use a [Personal Access Token](https://github.com/settings/tokens) instead of password
- For SSH: Make sure your SSH key is added to GitHub in Settings → SSH and GPG keys

### Remote Already Exists
```bash
# Remove old remote
git remote remove origin

# Add new remote
git remote add origin git@github.com:YOUR-USERNAME/scansnap-troubleshooting.git
```

### Push Rejected
```bash
# If GitHub has changes you don't have locally
git pull origin main --rebase
git push origin main
```

## Share Your Repository!

Once published, share the link:
- Twitter/X
- Reddit (r/homelab, r/networking)
- Hacker News
- LinkedIn
- Your blog

Example post:
```
🔧 Just published a network troubleshooting toolkit for Fujitsu ScanSnap iX1600 scanners!

Includes diagnostic scripts, Wireshark capture tools, and comprehensive guides for fixing connectivity issues.

https://github.com/YOUR-USERNAME/scansnap-troubleshooting

#networking #troubleshooting #opensource
```

Good luck! 🚀

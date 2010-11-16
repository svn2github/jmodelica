package mock;

import java.io.File;
import java.net.URI;
import java.util.Map;

import org.eclipse.core.resources.FileInfoMatcherDescription;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IPathVariableManager;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IProjectNature;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceFilterDescription;
import org.eclipse.core.resources.IResourceProxy;
import org.eclipse.core.resources.IResourceProxyVisitor;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourceAttributes;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IPluginDescriptor;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.core.runtime.content.IContentTypeMatcher;
import org.eclipse.core.runtime.jobs.ISchedulingRule;
import org.jmodelica.ide.IDEConstants;

@SuppressWarnings({ "deprecation", "unchecked" })
public class MockProject implements IProject {
    
public final static MockProject PROJECT = 
    new MockProject();



public void build(int kind, IProgressMonitor monitor) throws CoreException {
        
    }

    public void build(int kind, String builderName, Map args,
            IProgressMonitor monitor) throws CoreException {
    }

    public void close(IProgressMonitor monitor) throws CoreException {
    }

    public void create(IProgressMonitor monitor) throws CoreException {
    }

    public void create(IProjectDescription description, IProgressMonitor monitor)
            throws CoreException {
    }

    public void create(IProjectDescription description, int updateFlags,
            IProgressMonitor monitor) throws CoreException {
    }

    public void delete(boolean deleteContent, boolean force,
            IProgressMonitor monitor) throws CoreException {
    }

    public IContentTypeMatcher getContentTypeMatcher() throws CoreException {
        return null;
    }

    public IProjectDescription getDescription() throws CoreException {
        return null;
    }

    public IFile getFile(String name) {
        return null;
    }

    public IFolder getFolder(String name) {
        return null;
    }

    public IProjectNature getNature(String natureId) throws CoreException {
        return null;
    }

    public IPath getPluginWorkingLocation(IPluginDescriptor plugin) {
        return null;
    }

    public IProject[] getReferencedProjects() throws CoreException {
        return null;
    }

    public IProject[] getReferencingProjects() {
        return null;
    }

    public IPath getWorkingLocation(String id) {
        return null;
    }

    public boolean hasNature(String natureId) throws CoreException {
        return false;
    }

    public boolean isNatureEnabled(String natureId) throws CoreException {
        return false;
    }

    public boolean isOpen() {
        return false;
    }

    public void move(IProjectDescription description, boolean force,
            IProgressMonitor monitor) throws CoreException {
    }

    public void open(IProgressMonitor monitor) throws CoreException {
    }

    public void open(int updateFlags, IProgressMonitor monitor)
            throws CoreException {
    }

    public void setDescription(IProjectDescription description,
            IProgressMonitor monitor) throws CoreException {
    }

    public void setDescription(IProjectDescription description,
            int updateFlags, IProgressMonitor monitor) throws CoreException {
    }

    public boolean exists(IPath path) {
        return false;
    }

    public IFile[] findDeletedMembersWithHistory(int depth,
            IProgressMonitor monitor) throws CoreException {
        return null;
    }

    public IResource findMember(String name) {
        return null;
    }

    public IResource findMember(IPath path) {
        return null;
    }

    public IResource findMember(String name, boolean includePhantoms) {
        return null;
    }

    public IResource findMember(IPath path, boolean includePhantoms) {
        return null;
    }

    public String getDefaultCharset() throws CoreException {
        return null;
    }

    public String getDefaultCharset(boolean checkImplicit) throws CoreException {
        return null;
    }

    public IFile getFile(IPath path) {
        return null;
    }

    public IFolder getFolder(IPath path) {
        return null;
    }

    public IResource[] members() throws CoreException {
        return null;
    }

    public IResource[] members(boolean includePhantoms) throws CoreException {
        return null;
    }

    public IResource[] members(int memberFlags) throws CoreException {
        return null;
    }

    public void setDefaultCharset(String charset) throws CoreException {
    }

    public void setDefaultCharset(String charset, IProgressMonitor monitor)
            throws CoreException {
    }

    public void accept(IResourceVisitor visitor) throws CoreException {
    }

    public void accept(IResourceProxyVisitor visitor, int memberFlags)
            throws CoreException {
    }

    public void accept(IResourceVisitor visitor, int depth,
            boolean includePhantoms) throws CoreException {
    }

    public void accept(IResourceVisitor visitor, int depth, int memberFlags)
            throws CoreException {
    }

    public void clearHistory(IProgressMonitor monitor) throws CoreException {
    }

    public void copy(IPath destination, boolean force, IProgressMonitor monitor)
            throws CoreException {
    }

    public void copy(IPath destination, int updateFlags,
            IProgressMonitor monitor) throws CoreException {
    }

    public void copy(IProjectDescription description, boolean force,
            IProgressMonitor monitor) throws CoreException {
    }

    public void copy(IProjectDescription description, int updateFlags,
            IProgressMonitor monitor) throws CoreException {
    }

    public IMarker createMarker(String type) throws CoreException {
        return null;
    }

    public IResourceProxy createProxy() {
        return null;
    }

    public void delete(boolean force, IProgressMonitor monitor)
            throws CoreException {
    }

    public void delete(int updateFlags, IProgressMonitor monitor)
            throws CoreException {
    }

    public void deleteMarkers(String type, boolean includeSubtypes, int depth)
            throws CoreException {
    }

    public boolean exists() {
        return false;
    }

    public IMarker findMarker(long id) throws CoreException {
        return null;
    }

    public IMarker[] findMarkers(String type, boolean includeSubtypes, int depth)
            throws CoreException {
        return null;
    }

    public int findMaxProblemSeverity(String type, boolean includeSubtypes,
            int depth) throws CoreException {
        return 0;
    }

    public String getFileExtension() {
        return null;
    }

    public IPath getFullPath() {
        return null;
    }

    public long getLocalTimeStamp() {
        return 0;
    }

    public IPath getLocation() {
        return null;
    }

    public URI getLocationURI() {
        return null;
    }

    public IMarker getMarker(long id) {
        return null;
    }

    public long getModificationStamp() {
        return 0;
    }

    public String getName() {
        return null;
    }

    public IContainer getParent() {
        return null;
    }

    public Map getPersistentProperties() throws CoreException {
        return null;
    }

    public String getPersistentProperty(QualifiedName key) throws CoreException {
    	if (key.equals(IDEConstants.PREFERENCE_OPTIONS_PATH_ID))
    		return System.getenv("JMODELICA_HOME") + File.separator + "Options";
    	else if (key.equals(IDEConstants.PREFERENCE_LIBRARIES_ID)) 
    		return System.getenv("JMODELICA_SRC") + File.separator + "ThirdParty" + File.separator + "MSL";
    	else 
    		return null;
    }

    public IProject getProject() {
        return null;
    }

    public IPath getProjectRelativePath() {
        return null;
    }

    public IPath getRawLocation() {
        return new MockPath();
    }

    public URI getRawLocationURI() {
        return null;
    }

    public ResourceAttributes getResourceAttributes() {
        return null;
    }

    public Map getSessionProperties() throws CoreException {
        return null;
    }

    public Object getSessionProperty(QualifiedName key) throws CoreException {
        return null;
    }

    public int getType() {
        return 0;
    }

    public IWorkspace getWorkspace() {
        return null;
    }

    public boolean isAccessible() {
        return false;
    }

    public boolean isDerived() {
        return false;
    }

    public boolean isDerived(int options) {
        return false;
    }

    public boolean isHidden() {
        return false;
    }

    public boolean isHidden(int options) {
        return false;
    }

    public boolean isLinked() {
        return false;
    }

    public boolean isLinked(int options) {
        return false;
    }

    public boolean isLocal(int depth) {
        return false;
    }

    public boolean isPhantom() {
        return false;
    }

    public boolean isReadOnly() {
        return false;
    }

    public boolean isSynchronized(int depth) {
        return false;
    }

    public boolean isTeamPrivateMember() {
        return false;
    }

    public boolean isTeamPrivateMember(int options) {
        return false;
    }

    public void move(IPath destination, boolean force, IProgressMonitor monitor)
            throws CoreException {
    }

    public void move(IPath destination, int updateFlags,
            IProgressMonitor monitor) throws CoreException {
    }

    public void move(IProjectDescription description, int updateFlags,
            IProgressMonitor monitor) throws CoreException {
    }

    public void move(IProjectDescription description, boolean force,
            boolean keepHistory, IProgressMonitor monitor) throws CoreException {
    }

    public void refreshLocal(int depth, IProgressMonitor monitor)
            throws CoreException {
    }

    public void revertModificationStamp(long value) throws CoreException {
    }

    public void setDerived(boolean isDerived) throws CoreException {
    }

    public void setHidden(boolean isHidden) throws CoreException {
    }

    public void setLocal(boolean flag, int depth, IProgressMonitor monitor)
            throws CoreException {
    }

    public long setLocalTimeStamp(long value) throws CoreException {
        return 0;
    }

    public void setPersistentProperty(QualifiedName key, String value)
            throws CoreException {
    }

    public void setReadOnly(boolean readOnly) {
    }

    public void setResourceAttributes(ResourceAttributes attributes)
            throws CoreException {
    }

    public void setSessionProperty(QualifiedName key, Object value)
            throws CoreException {
    }

    public void setTeamPrivateMember(boolean isTeamPrivate)
            throws CoreException {
    }

    public void touch(IProgressMonitor monitor) throws CoreException {
    }

    public Object getAdapter(Class adapter) {
        return null;
    }

    public boolean contains(ISchedulingRule rule) {
        return false;
    }

    public boolean isConflicting(ISchedulingRule rule) {
        return false;
    }

	@Override
	public IResourceFilterDescription createFilter(int type,
			FileInfoMatcherDescription matcherDescription, int updateFlags,
			IProgressMonitor monitor) throws CoreException {
		return null;
	}

	@Override
	public IResourceFilterDescription[] getFilters() throws CoreException {
		return null;
	}

	@Override
	public IPathVariableManager getPathVariableManager() {
		return null;
	}

	@Override
	public boolean isVirtual() {
		return false;
	}

	@Override
	public void setDerived(boolean isDerived, IProgressMonitor monitor)
			throws CoreException {
	}

	@Override
	public void loadSnapshot(int options, URI snapshotLocation,
			IProgressMonitor monitor) throws CoreException {
	}

	@Override
	public void saveSnapshot(int options, URI snapshotLocation,
			IProgressMonitor monitor) throws CoreException {
	}
}

package org.jastadd.ed.core.service.browsing;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.swt.graphics.Image;
import org.jastadd.ed.core.model.node.IASTNode;
import org.jastadd.ed.core.model.node.ILocalRootNode;
import org.jastadd.ed.core.model.node.ITextViewNode;
import org.jastadd.ed.core.model.node.ITreeViewNode;
import org.jastadd.ed.core.service.view.ITreeNode;
import org.jastadd.ed.core.service.view.TreeNode;
import org.jastadd.ed.core.service.view.outline.IOutlineNode;

public class BrowsingNode extends TreeNode {

	
	// Factory method
	
	
	public static List<ITreeNode> convertResult(Collection<? extends IASTNode> results) {
		Map<IASTNode, BrowsingNode> map = new HashMap<IASTNode,BrowsingNode>();
		Map<String, BrowsingNode> rootMap = new HashMap<String, BrowsingNode>();
		
		List<ITreeNode> roots = new ArrayList<ITreeNode>();
		
		for(IASTNode n : results) {
			
			IASTNode child = n;
			
			// Create tree view node
			BrowsingNode refNode = createNode(map, child);
			
			// Look for parent nodes to display in view
			
			IASTNode parent = child.getParent();
			while(parent != null) {
				
				if(parent instanceof ILocalRootNode) {
					ILocalRootNode rootNode = (ILocalRootNode)parent;
					String fileName = rootNode.getFile().getName();
					if(hasRootNode(rootMap, fileName)) {
						BrowsingNode parentNode = rootMap.get(fileName);
						parentNode.addChild(refNode);
						refNode = parentNode;
					} else {
						BrowsingNode parentNode = createNode(map, parent);
						parentNode.addChild(refNode);
						refNode = parentNode;
						rootMap.put(fileName, parentNode);
						roots.add(parentNode);
					}
					//reachedRoot = true;
					
					break; // Last level
				} else if (parent instanceof IOutlineNode) {
					if (((IOutlineNode)parent).showInOutline()) {
						boolean hasNode = hasNode(map, parent);
						BrowsingNode parentNode = createNode(map, parent);
						parentNode.addChild(refNode);
						refNode = parentNode;
						if (hasNode) break; // Parent node is already visible
					} //else break;
				}
				
				parent = parent.getParent();
			}
			
			
			//if(reachedRoot) //!roots.contains(refNode))
				//roots.add(refNode); 
		}
		//sortNodes(roots);
		return roots;
	}
	
	private static BrowsingNode createNode(Map<IASTNode,BrowsingNode> map, IASTNode astNode) {
		if(map.containsKey(astNode))
			return map.get(astNode);
		String label = astNode.getClass().getName();
		Image image = null;
		if (astNode instanceof IBrowsingNode) {
			IBrowsingNode browsingNode = (IBrowsingNode)astNode;
			label = browsingNode.browsingLabel();
			image = browsingNode.browsingImage();
		} else if (astNode instanceof ILocalRootNode) {
			ILocalRootNode localRootNode = (ILocalRootNode)astNode;
			label = localRootNode.getFile().getName();
			image = astNode instanceof ITreeViewNode ? ((ITreeViewNode)astNode).treeViewImage() : null;
		} else if (astNode instanceof IOutlineNode) { 
			IOutlineNode outlineNode = (IOutlineNode)astNode;
			label = outlineNode.outlineLabel();
			image = outlineNode.outlineImage();
		} else {
			label = astNode.getClass().getName();
			image = null;
		}
		BrowsingNode node = new BrowsingNode((ITreeViewNode)astNode, label, image);
		map.put(astNode, node);
		return node;
	}

	private static boolean hasNode(Map<IASTNode,BrowsingNode> map, IASTNode astNode) {
		return map.containsKey(astNode);
	}
	
	private static boolean hasRootNode(Map<String, BrowsingNode> map, String fileName) {
		return map.containsKey(fileName);
	}
	
	protected BrowsingNode(ITreeViewNode node, String label, Image image) {
		super(node, label, image);
	}

	Comparator<ITreeViewNode> childComp = new Comparator<ITreeViewNode>() {
		@Override
		public int compare(ITreeViewNode a, ITreeViewNode b) {
			if (a instanceof ILocalRootNode && b instanceof ILocalRootNode) {
				return a.treeViewLabel().compareTo(b.treeViewLabel());
			} else if (a instanceof ITextViewNode && b instanceof ITextViewNode) {
				Integer aOffset = Integer.valueOf(((ITextViewNode)a).startTextOffset());
				Integer bOffset = Integer.valueOf(((ITextViewNode)b).startTextOffset());
				return aOffset.compareTo(bOffset);
			}
			return 0;
		}
	};
	
	@Override
	public TreeNode addChild(TreeNode node) {
		node.setParent(this);
		int index = 0;
		for (ITreeNode child : fChildren) {
			if (childComp.compare(child.getNode(), node.getNode()) > 0) {
				break;
			}
			index++;
		}
		fChildren.add(index, node);
		return this;
	}

}
